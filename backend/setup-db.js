const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function setupDatabase() {
  let connection;
  try {
    console.log('🔄 Connecting to MySQL...');
    
    // Buat koneksi awal (tanpa database untuk CREATE DATABASE)
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: process.env.DB_PORT || 3306,
    });

    console.log('✅ Connected to MySQL successfully!');
    
    const dbName = process.env.DB_NAME || 'honkai_star_retail';
    
    // Step 1: Buat database jika belum ada
    console.log(`\n📊 Creating database '${dbName}'...`);
    try {
      await connection.query(`CREATE DATABASE IF NOT EXISTS ${dbName}`);
      console.log(`✅ Database ready: ${dbName}`);
    } catch (err) {
      if (err.code !== 'ER_DB_CREATE_EXISTS') throw err;
    }
    
    // Close koneksi lama dan buat yang baru WITH database
    await connection.end();
    
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: process.env.DB_PORT || 3306,
      database: dbName,
    });
    
    console.log(`✅ Connected to database: ${dbName}\n`);

    // Step 2: Baca SQL file dan eksekusi
    const sqlFile = path.join(__dirname, 'database.sql');
    let sqlScript = fs.readFileSync(sqlFile, 'utf8');

    // Hapus comments (--) dan /* */ 
    sqlScript = sqlScript
      .replace(/--[^\n]*/g, '') // Remove -- comments
      .replace(/\/\*[\s\S]*?\*\//g, ''); // Remove /* */ comments
    
    // Hapus CREATE DATABASE dan USE statements
    sqlScript = sqlScript
      .replace(/CREATE\s+DATABASE[^;]*;/gi, '')
      .replace(/USE\s+[^;]*;/gi, '');

    // Split berdasarkan semicolon untuk multiple statements
    const statements = sqlScript
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0);

    console.log(`📝 Found ${statements.length} SQL statements to execute...\n`);

    // Step 3: Execute setiap statement
    for (const statement of statements) {
      try {
        await connection.query(statement);
        const preview = statement.substring(0, 50).replace(/\n/g, ' ');
        console.log(`✅ Executed: ${preview}...`);
      } catch (err) {
        if (err.code === 'ER_TABLE_EXISTS_ERROR') {
          console.log(`⚠️  Table already exists (skipped)`);
        } else if (err.code === 'ER_DUP_ENTRY') {
          console.log(`⚠️  Duplicate data (skipped)`);
        } else {
          throw err;
        }
      }
    }

    await connection.end();

    console.log('\n✅ Database setup completed successfully!');
    console.log('\n📊 Summary:');
    console.log('   Database: honkai_star_retail');
    console.log('   Tables: users, resources, purchases');
    console.log('   Sample data loaded: Yes');
    console.log('\n🎉 You can now run the application!');

  } catch (error) {
    console.error('\n❌ Error during database setup:');
    console.error('Error:', error.message);
    
    if (error.code === 'PROTOCOL_CONNECTION_LOST') {
      console.error('\n🔍 Possible solutions:');
      console.error('   1. Make sure MySQL Server is running');
      console.error('   2. Check if MySQL is listening on localhost:3306');
      console.error('   3. Verify root username and password in .env');
    } else if (error.code === 'ECONNREFUSED') {
      console.error('\n🔍 Connection refused - MySQL Server not running');
      console.error('   Start MySQL and try again');
    }
    
    process.exit(1);
  }
}

setupDatabase();
