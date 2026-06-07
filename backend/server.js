require('dotenv').config();
const REQUIRED_ENV = ['DB_HOST', 'DB_USER', 'DB_NAME', 'DB_PORT', 'JWT_SECRET', 'FRONTEND_URL'];
const missingEnv = REQUIRED_ENV.filter(key => !process.env[key]);
if (missingEnv.length > 0) {
  console.error('❌ Environment variable tidak ditemukan:', missingEnv.join(', '));
  console.error('Pastikan file .env sudah ada dan berisi semua variabel yang dibutuhkan.');
  process.exit(1); // Stop server dengan pesan jelas, bukan crash misterius
}
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const FacebookStrategy = require('passport-facebook').Strategy;
const TwitterStrategy = require('passport-twitter').Strategy;
const session = require('express-session');

const app = express();

// Middleware
app.use(cors({
  origin: [process.env.FRONTEND_URL || 'http://10.0.2.2:3000', 'http://10.0.2.2:5000'],
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

app.use(session({
  secret: process.env.SESSION_SECRET || process.env.JWT_SECRET || 'honkai-session-secret',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false
  }
}));
app.use(passport.initialize());
app.use(passport.session());

// MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

(async () => {
  try {
    const conn = await pool.getConnection();
    console.log('✅ Koneksi database berhasil');
    
    // Migration: Update avatar_url column to LONGTEXT if needed
    try {
      await conn.query(
        'ALTER TABLE users MODIFY COLUMN avatar_url LONGTEXT'
      );
      console.log('✅ Migration: avatar_url column updated to LONGTEXT');
    } catch (migrationErr) {
      console.log('ℹ️ Migration skipped (column may already be LONGTEXT)');
    }

    const ensureColumn = async (column, definition) => {
      const [rows] = await conn.query('SHOW COLUMNS FROM users LIKE ?', [column]);
      if (rows.length === 0) {
        await conn.query(`ALTER TABLE users ADD COLUMN ${column} ${definition}`);
        console.log(`✅ Migration: added column ${column}`);
      }
    };

    await ensureColumn('facebook_id', 'VARCHAR(255)');
    await ensureColumn('twitter_id', 'VARCHAR(255)');
    await ensureColumn('oauth_provider', 'VARCHAR(50)');
    await ensureColumn('oauth_id', 'VARCHAR(255)');

    conn.release();
  } catch (err) {
    console.error('❌ Koneksi database gagal:', err.message);
    console.error('Periksa DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT di file .env');
    process.exit(1);
  }
})();

// Middleware untuk verify JWT
const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'Token tidak ditemukan' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Token tidak valid' });
  }
};

const generateToken = (payload) => {
  const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
  
  // Validate token meets requirements
  if (!token || typeof token !== 'string') {
    throw new Error('Token generation failed');
  }
  
  if (token.length < 20) {
    throw new Error(`Token length ${token.length} is less than 20 characters`);
  }
  
  const isAlphanumeric = /^[a-zA-Z0-9._-]+$/.test(token);
  if (!isAlphanumeric) {
    console.warn('Token contains non-alphanumeric characters (contains . and - which is normal for JWT)');
  }
  
  return token;
};

const oauthUserColumn = (provider) => {
  if (provider === 'google') return 'google_id';
  if (provider === 'facebook') return 'facebook_id';
  if (provider === 'twitter') return 'twitter_id';
  return null;
};

const findOrCreateOAuthUser = async (provider, profile) => {
  const oauthColumn = oauthUserColumn(provider);
  if (!oauthColumn) {
    throw new Error('Provider OAuth tidak didukung');
  }

  const email = profile.emails?.[0]?.value || `${provider}_${profile.id}@oauth.honkai.local`;
  const usernameBase = profile.username || profile.displayName?.replace(/\s+/g, '_').toLowerCase() || `${provider}_${profile.id}`;
  const username = `${usernameBase}_${Math.floor(Math.random() * 10000)}`;

  const conn = await pool.getConnection();
  try {
    const [existingByProvider] = await conn.query(
      `SELECT * FROM users WHERE ${oauthColumn} = ?`,
      [profile.id]
    );

    if (existingByProvider.length > 0) {
      return existingByProvider[0];
    }

    if (email) {
      const [existingByEmail] = await conn.query('SELECT * FROM users WHERE email = ?', [email]);
      if (existingByEmail.length > 0) {
        await conn.query(
          `UPDATE users SET ${oauthColumn} = ?, oauth_provider = ?, oauth_id = ? WHERE id = ?`,
          [profile.id, provider, profile.id, existingByEmail[0].id]
        );
        return { ...existingByEmail[0], [oauthColumn]: profile.id, oauth_provider: provider, oauth_id: profile.id };
      }
    }

    const newUsername = email ? email.split('@')[0] : username;
    const [result] = await conn.query(
      'INSERT INTO users (email, username, password, role, first_name, last_name, avatar_url, google_id, facebook_id, twitter_id, oauth_provider, oauth_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        email,
        newUsername,
        null,
        'user',
        profile.name?.givenName || profile.name?.firstName || '',
        profile.name?.familyName || profile.name?.lastName || '',
        profile.photos?.[0]?.value || '',
        provider === 'google' ? profile.id : null,
        provider === 'facebook' ? profile.id : null,
        provider === 'twitter' ? profile.id : null,
        provider,
        profile.id
      ]
    );

    const [newUserRows] = await conn.query('SELECT * FROM users WHERE id = ?', [result.insertId]);
    return newUserRows[0];
  } finally {
    conn.release();
  }
};

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const conn = await pool.getConnection();
    const [users] = await conn.query('SELECT * FROM users WHERE id = ?', [id]);
    conn.release();
    done(null, users.length > 0 ? users[0] : null);
  } catch (err) {
    done(err, null);
  }
});

const setupOAuthStrategies = () => {
  if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET && process.env.GOOGLE_CALLBACK_URL) {
    passport.use(new GoogleStrategy({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: process.env.GOOGLE_CALLBACK_URL
    }, async (accessToken, refreshToken, profile, done) => {
      try {
        const user = await findOrCreateOAuthUser('google', profile);
        done(null, user);
      } catch (err) {
        done(err, null);
      }
    }));
  }

  if (process.env.FACEBOOK_APP_ID && process.env.FACEBOOK_APP_SECRET && process.env.FACEBOOK_CALLBACK_URL) {
    passport.use(new FacebookStrategy({
      clientID: process.env.FACEBOOK_APP_ID,
      clientSecret: process.env.FACEBOOK_APP_SECRET,
      callbackURL: process.env.FACEBOOK_CALLBACK_URL,
      profileFields: ['id', 'displayName', 'emails', 'name', 'picture.type(large)']
    }, async (accessToken, refreshToken, profile, done) => {
      try {
        const user = await findOrCreateOAuthUser('facebook', profile);
        done(null, user);
      } catch (err) {
        done(err, null);
      }
    }));
  }

  if (process.env.TWITTER_CONSUMER_KEY && process.env.TWITTER_CONSUMER_SECRET && process.env.TWITTER_CALLBACK_URL) {
    passport.use(new TwitterStrategy({
      consumerKey: process.env.TWITTER_CONSUMER_KEY,
      consumerSecret: process.env.TWITTER_CONSUMER_SECRET,
      callbackURL: process.env.TWITTER_CALLBACK_URL,
      includeEmail: true
    }, async (token, tokenSecret, profile, done) => {
      try {
        const user = await findOrCreateOAuthUser('twitter', profile);
        done(null, user);
      } catch (err) {
        done(err, null);
      }
    }));
  }
};

setupOAuthStrategies();

// ==================== AUTHENTICATION ENDPOINTS ====================

const oauthSuccessResponse = (res, user) => {
  const tokenData = {
    id: user.id,
    email: user.email,
    username: user.username,
    role: user.role
  };
  const token = generateToken(tokenData);

  // Return HTML page dengan token visible untuk copy-paste
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Login Berhasil</title>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
          background: linear-gradient(135deg, #001a33 0%, #330066 50%, #003d99 100%);
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 0;
          padding: 20px;
        }
        .container {
          background: rgba(20, 20, 40, 0.95);
          border-radius: 12px;
          padding: 40px;
          max-width: 500px;
          width: 100%;
          border: 1px solid rgba(100, 200, 255, 0.2);
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        h1 {
          color: #64c8ff;
          text-align: center;
          margin-top: 0;
        }
        .success-icon {
          text-align: center;
          font-size: 48px;
          margin-bottom: 20px;
        }
        .user-info {
          background: rgba(50, 50, 80, 0.5);
          padding: 15px;
          border-radius: 8px;
          margin-bottom: 20px;
          text-align: center;
        }
        .user-info p {
          color: #c0c0c0;
          margin: 8px 0;
        }
        .user-info strong {
          color: #64c8ff;
        }
        .token-section {
          background: rgba(50, 50, 80, 0.5);
          padding: 15px;
          border-radius: 8px;
          margin: 20px 0;
        }
        .token-label {
          color: #c0c0c0;
          font-size: 12px;
          margin-bottom: 8px;
          text-transform: uppercase;
        }
        .token-box {
          background: rgba(10, 10, 30, 0.8);
          border: 1px solid #64c8ff;
          border-radius: 6px;
          padding: 12px;
          overflow-x: auto;
          word-break: break-all;
          font-family: 'Courier New', monospace;
          color: #64c8ff;
          font-size: 12px;
          margin-bottom: 10px;
          max-height: 150px;
          overflow-y: auto;
        }
        .copy-btn {
          width: 100%;
          padding: 10px;
          background: linear-gradient(135deg, #3366cc 0%, #0066ff 100%);
          color: white;
          border: none;
          border-radius: 6px;
          cursor: pointer;
          font-weight: bold;
          font-size: 14px;
          transition: transform 0.2s;
        }
        .copy-btn:hover {
          transform: translateY(-2px);
        }
        .instructions {
          background: rgba(100, 100, 150, 0.2);
          padding: 15px;
          border-left: 3px solid #64c8ff;
          border-radius: 4px;
          color: #c0c0c0;
          font-size: 14px;
          margin-top: 20px;
        }
        .instructions p {
          margin: 8px 0;
        }
        .json-response {
          background: rgba(50, 50, 80, 0.5);
          padding: 15px;
          border-radius: 8px;
          margin-top: 20px;
        }
        pre {
          background: rgba(10, 10, 30, 0.8);
          padding: 10px;
          border-radius: 6px;
          color: #64c8ff;
          font-size: 11px;
          overflow-x: auto;
          max-height: 200px;
          overflow-y: auto;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="success-icon">✅</div>
        <h1>Login Berhasil!</h1>
        
        <div class="user-info">
          <p><strong>${user.username}</strong></p>
          <p style="font-size: 12px; color: #888;">${user.email}</p>
          <p style="font-size: 12px; color: #888;">Role: <strong style="color: #64c8ff;">${user.role}</strong></p>
        </div>

        <div class="token-section">
          <div class="token-label">Bearer Token (untuk Flutter App)</div>
          <div class="token-box" id="tokenBox">${token}</div>
          <button class="copy-btn" onclick="copyToken()">📋 Copy Token</button>
        </div>

        <div class="json-response">
          <div class="token-label">JSON Response</div>
          <pre id="jsonResponse"></pre>
        </div>

        <div class="instructions">
          <p><strong>Langkah berikutnya:</strong></p>
          <ol>
            <li>Copy token di atas</li>
            <li>Kembali ke Flutter app</li>
            <li>Paste token di dialog box</li>
            <li>Tap tombol "Verifikasi"</li>
          </ol>
        </div>
      </div>

      <script>
        function copyToken() {
          const token = document.getElementById('tokenBox').innerText;
          navigator.clipboard.writeText(token).then(() => {
            alert('Token copied to clipboard!');
          }).catch(() => {
            alert('Failed to copy. Please copy manually.');
          });
        }

        // Display JSON response
        const jsonData = {
          message: 'Login berhasil menggunakan OAuth eksternal',
          token: '${token}',
          user: {
            id: ${user.id},
            email: '${user.email}',
            username: '${user.username}',
            role: '${user.role}',
            firstName: '${user.first_name || ''}',
            lastName: '${user.last_name || ''}',
            avatarUrl: '${user.avatar_url || ''}'
          }
        };
        document.getElementById('jsonResponse').textContent = JSON.stringify(jsonData, null, 2);
      </script>
    </body>
    </html>
  `;

  res.header('Content-Type', 'text/html');
  res.send(html);
};

app.get('/auth/google', (req, res, next) => {
  if (!passport._strategy('google')) {
    return res.status(501).json({ error: 'Google OAuth belum dikonfigurasi' });
  }
  passport.authenticate('google', { scope: ['profile', 'email'] })(req, res, next);
});

app.get('/auth/google/callback', (req, res, next) => {
  if (!passport._strategy('google')) {
    return res.status(501).json({ error: 'Google OAuth belum dikonfigurasi' });
  }
  passport.authenticate('google', { session: false, failureRedirect: '/auth/failure' })(req, res, next);
}, (req, res) => {
  oauthSuccessResponse(res, req.user);
});

app.get('/auth/facebook', (req, res, next) => {
  if (!passport._strategy('facebook')) {
    return res.status(501).json({ error: 'Facebook OAuth belum dikonfigurasi' });
  }
  passport.authenticate('facebook', { scope: ['email'] })(req, res, next);
});

app.get('/auth/facebook/callback', (req, res, next) => {
  if (!passport._strategy('facebook')) {
    return res.status(501).json({ error: 'Facebook OAuth belum dikonfigurasi' });
  }
  passport.authenticate('facebook', { session: false, failureRedirect: '/auth/failure' })(req, res, next);
}, (req, res) => {
  oauthSuccessResponse(res, req.user);
});

app.get('/auth/twitter', (req, res, next) => {
  if (!passport._strategy('twitter')) {
    return res.status(501).json({ error: 'Twitter OAuth belum dikonfigurasi' });
  }
  passport.authenticate('twitter')(req, res, next);
});

app.get('/auth/twitter/callback', (req, res, next) => {
  if (!passport._strategy('twitter')) {
    return res.status(501).json({ error: 'Twitter OAuth belum dikonfigurasi' });
  }
  passport.authenticate('twitter', { session: false, failureRedirect: '/auth/failure' })(req, res, next);
}, (req, res) => {
  oauthSuccessResponse(res, req.user);
});

app.get('/auth/failure', (req, res) => {
  res.status(401).json({ error: 'OAuth eksternal gagal atau dibatalkan' });
});

// Register User
app.post('/auth/register', async (req, res) => {
  try {
    const { email, username, password, firstName, lastName, role = 'user' } = req.body;

    // Validasi
    if (!email || !username || !password) {
      return res.status(400).json({ error: 'Email, username, dan password harus diisi' });
    }

    if (password.length < 8) {
      return res.status(400).json({ error: 'Password harus minimal 8 karakter' });
    }

    // Validasi role
    const validRoles = ['user', 'admin'];
    const userRole = validRoles.includes(role) ? role : 'user';

    // Validasi email berdasarkan role
    if (userRole === 'user' && !email.endsWith('@gmail.com')) {
      return res.status(400).json({ error: 'User harus menggunakan email @gmail.com' });
    }

    if (userRole === 'admin' && !email.endsWith('@admin.com')) {
      return res.status(400).json({ error: 'Admin harus menggunakan email @admin.com' });
    }

    const conn = await pool.getConnection();

    // Cek apakah email atau username sudah ada
    const [existing] = await conn.query('SELECT id FROM users WHERE email = ? OR username = ?', [email, username]);
    
    if (existing.length > 0) {
      conn.release();
      return res.status(400).json({ error: 'Email atau username sudah terdaftar' });
    }

    // Hash password
    const hashedPassword = await bcryptjs.hash(password, 10);

    // Insert user baru dengan role
    const [result] = await conn.query(
      'INSERT INTO users (email, username, password, first_name, last_name, role) VALUES (?, ?, ?, ?, ?, ?)',
      [email, username, hashedPassword, firstName || '', lastName || '', userRole]
    );

    conn.release();

    // Buat token dengan role
    const user = { id: result.insertId, email, username, role: userRole };
    const token = jwt.sign(user, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({ 
      message: 'Registrasi berhasil',
      token,
      user 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Registrasi gagal' });
  }
});

// Login User
app.post('/auth/login', async (req, res) => {
  try {
    const { email, password, role = 'user' } = req.body;

    // Validasi
    if (!email || !password) {
      return res.status(400).json({ error: 'Email dan password harus diisi' });
    }

    // Validasi email berdasarkan role yang dipilih
    if (role === 'user' && !email.endsWith('@gmail.com')) {
      return res.status(400).json({ error: 'User harus menggunakan email @gmail.com' });
    }

    if (role === 'admin' && !email.endsWith('@admin.com')) {
      return res.status(400).json({ error: 'Admin harus menggunakan email @admin.com' });
    }

    const conn = await pool.getConnection();

    // Cari user berdasarkan email
    const [users] = await conn.query('SELECT * FROM users WHERE email = ?', [email]);
    
    if (users.length === 0) {
      conn.release();
      return res.status(401).json({ error: 'Email atau password salah' });
    }

    const user = users[0];

    // Validasi role dari database sesuai dengan yang dipilih
    if (user.role !== role) {
      conn.release();
      return res.status(401).json({ error: `Email ini terdaftar sebagai ${user.role}, bukan ${role}` });
    }

    // Cek password
    const isPasswordValid = await bcryptjs.compare(password, user.password);
    
    if (!isPasswordValid) {
      conn.release();
      return res.status(401).json({ error: 'Email atau password salah' });
    }

    conn.release();

    // Buat token
    const tokenData = { 
      id: user.id, 
      email: user.email, 
      username: user.username,
      role: user.role 
    };
    const token = jwt.sign(tokenData, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({ 
      message: 'Login berhasil',
      token,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
        avatarUrl: user.avatar_url
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Login gagal' });
  }
});

// Verify Token (for checking if token is valid)
app.get('/auth/verify', verifyToken, async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const [users] = await conn.query('SELECT id, email, username, role, first_name, last_name, avatar_url FROM users WHERE id = ?', [req.user.id]);
    conn.release();

    if (users.length === 0) {
      return res.status(404).json({ error: 'User tidak ditemukan' });
    }

    const user = users[0];
    res.json({
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
        avatarUrl: user.avatar_url
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Verifikasi token gagal' });
  }
});

// POST - Upload avatar (Update user profile picture)
app.post('/auth/upload-avatar', verifyToken, async (req, res) => {
  try {
    const { avatar } = req.body; // avatar as base64 string
    
    if (!avatar) {
      return res.status(400).json({ error: 'Avatar tidak boleh kosong' });
    }

    const conn = await pool.getConnection();
    
    // Update user avatar
    await conn.query(
      'UPDATE users SET avatar_url = ? WHERE id = ?',
      [avatar, req.user.id]
    );

    // Get updated user
    const [users] = await conn.query(
      'SELECT id, email, username, role, first_name, last_name, avatar_url FROM users WHERE id = ?',
      [req.user.id]
    );
    conn.release();

    const user = users[0];
    res.json({
      message: 'Avatar berhasil diupload',
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        role: user.role,
        firstName: user.first_name,
        lastName: user.last_name,
        avatarUrl: user.avatar_url
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal upload avatar' });
  }
});

// ==================== RESOURCES (PRODUCTS) ENDPOINTS ====================

// GET - Get all resources (dengan filter tipe)
app.get('/resources', async (req, res) => {
  try {
    const { type } = req.query;
    const conn = await pool.getConnection();

    let query = 'SELECT * FROM resources';
    const params = [];

    if (type) {
      query += ' WHERE type = ?';
      params.push(type);
    }

    query += ' ORDER BY created_at DESC';

    console.log('GET /resources', { query, params });

    const [resources] = await conn.query(query, params);
    conn.release();

    res.json(resources);
  } catch (error) {
    console.error('GET /resources error:', error);
    res.status(500).json({ error: 'Gagal mengambil data resources' });
  }
});

// GET - Get single resource by ID
app.get('/resources/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const conn = await pool.getConnection();
    
    const [resources] = await conn.query('SELECT * FROM resources WHERE id = ?', [id]);
    conn.release();

    if (resources.length === 0) {
      return res.status(404).json({ error: 'Resource tidak ditemukan' });
    }

    res.json(resources[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil detail resource' });
  }
});

// POST - Create new resource (Admin only)
app.post('/resources', verifyToken, async (req, res) => {
  try {
    // Cek apakah user adalah admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Hanya admin yang dapat menambah resource' });
    }

    const { name, type, description, stock, imageUrl, price } = req.body;

    // Validasi
    if (!name || !type || !stock || !price) {
      return res.status(400).json({ error: 'Nama, tipe, stok, dan harga harus diisi' });
    }

    if (isNaN(stock) || stock <= 0) {
      return res.status(400).json({ error: 'Stok harus berupa angka positif' });
    }

    if (isNaN(price) || price <= 0) {
      return res.status(400).json({ error: 'Harga harus berupa angka positif' });
    }

    const conn = await pool.getConnection();

    const [result] = await conn.query(
      'INSERT INTO resources (name, type, description, stock, image_url, price, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [name, type, description || '', stock, imageUrl || '', price, req.user.id]
    );

    conn.release();

    res.status(201).json({
      message: 'Resource berhasil ditambahkan',
      id: result.insertId
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal menambah resource' });
  }
});

// PUT/PATCH - Update resource (Admin only)
app.put('/resources/:id', verifyToken, async (req, res) => {
  try {
    // Cek apakah user adalah admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Hanya admin yang dapat mengubah resource' });
    }

    const { id } = req.params;
    const { name, type, description, stock, imageUrl, price } = req.body;

    // Validasi
    if (!name || !type) {
      return res.status(400).json({ error: 'Nama dan tipe tidak boleh kosong' });
    }

    if (stock !== undefined && (isNaN(stock) || stock < 0)) {
      return res.status(400).json({ error: 'Stok harus berupa angka' });
    }

    if (price !== undefined && (isNaN(price) || price <= 0)) {
      return res.status(400).json({ error: 'Harga harus berupa angka positif' });
    }

    const conn = await pool.getConnection();

    const [result] = await conn.query(
      'UPDATE resources SET name = ?, type = ?, description = ?, stock = ?, image_url = ?, price = ? WHERE id = ?',
      [name, type, description || '', stock, imageUrl || '', price, id]
    );

    conn.release();

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Resource tidak ditemukan' });
    }

    res.json({ message: 'Resource berhasil diperbarui' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengubah resource' });
  }
});

// DELETE - Delete resource (Admin only)
app.delete('/resources/:id', verifyToken, async (req, res) => {
  try {
    // Cek apakah user adalah admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Hanya admin yang dapat menghapus resource' });
    }

    const { id } = req.params;
    const conn = await pool.getConnection();

    const [result] = await conn.query('DELETE FROM resources WHERE id = ?', [id]);

    conn.release();

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Resource tidak ditemukan' });
    }

    res.json({ message: 'Resource berhasil dihapus' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal menghapus resource' });
  }
});

// ==================== PURCHASES ENDPOINTS ====================

// POST - Create purchase (User buy resource)
app.post('/purchases', verifyToken, async (req, res) => {
  try {
    const { resourceId, quantity } = req.body;

    // Validasi
    if (!resourceId || !quantity) {
      return res.status(400).json({ error: 'Resource ID dan quantity harus diisi' });
    }

    if (isNaN(quantity) || quantity <= 0) {
      return res.status(400).json({ error: 'Quantity harus berupa angka positif' });
    }

    const conn = await pool.getConnection();

    // Get resource untuk cek stok dan harga
    const [resources] = await conn.query('SELECT * FROM resources WHERE id = ?', [resourceId]);

    if (resources.length === 0) {
      conn.release();
      return res.status(404).json({ error: 'Resource tidak ditemukan' });
    }

    const resource = resources[0];

    if (resource.stock < quantity) {
      conn.release();
      return res.status(400).json({ error: 'Stok tidak cukup' });
    }

    const totalPrice = resource.price * quantity;

    // Insert purchase
    const [purchaseResult] = await conn.query(
      'INSERT INTO purchases (user_id, resource_id, quantity, total_price) VALUES (?, ?, ?, ?)',
      [req.user.id, resourceId, quantity, totalPrice]
    );

    // Update resource stock
    await conn.query(
      'UPDATE resources SET stock = stock - ? WHERE id = ?',
      [quantity, resourceId]
    );

    conn.release();

    res.status(201).json({
      message: 'Pembelian berhasil',
      purchaseId: purchaseResult.insertId
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal melakukan pembelian' });
  }
});

// GET - Get user purchase history
app.get('/purchases/history', verifyToken, async (req, res) => {
  try {
    const conn = await pool.getConnection();

    const [purchases] = await conn.query(`
      SELECT p.*, r.name, r.type, r.price, r.image_url 
      FROM purchases p
      JOIN resources r ON p.resource_id = r.id
      WHERE p.user_id = ?
      ORDER BY p.purchase_date DESC
    `, [req.user.id]);

    conn.release();

    res.json(purchases);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil riwayat pembelian' });
  }
});

// ==================== USER ENDPOINTS ====================

// GET - Get user profile
app.get('/users/profile', verifyToken, async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const [users] = await conn.query('SELECT id, email, username, role, first_name, last_name, avatar_url FROM users WHERE id = ?', [req.user.id]);
    conn.release();

    if (users.length === 0) {
      return res.status(404).json({ error: 'User tidak ditemukan' });
    }

    const user = users[0];
    res.json({
      id: user.id,
      email: user.email,
      username: user.username,
      role: user.role,
      firstName: user.first_name,
      lastName: user.last_name,
      avatarUrl: user.avatar_url
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Gagal mengambil profil user' });
  }
});

// Root route
app.get('/', (req, res) => {
  res.json({ 
    message: 'API Server aktif',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: ['/auth/register', '/auth/login', '/auth/verify'],
      resources: '/resources',
      purchases: '/purchases/history',
      profile: '/users/profile'
    }
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint tidak ditemukan' });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

module.exports = app;
