# Honkai Star Retail - Complete Application Documentation

## Deskripsi Aplikasi

Honkai Star Retail adalah aplikasi mobile yang menyediakan berbagai sumber daya galaksi (galactic resources) dan light cones yang dapat dibeli oleh pengguna. Aplikasi ini memiliki 2 peran utama:

- **User**: Dapat melihat dan membeli resource/produk
- **Admin**: Dapat menambah, mengubah, dan menghapus resource

## Arsitektur Sistem

### 1. **Backend (Node.js + Express)**
- Port: 5000
- Database: MySQL
- Authentication: JWT + OAuth (Google)
- REST API dengan Bearer Token verification

### 2. **Frontend (Flutter Mobile App)**
- Target Platforms: iOS, Android, Web
- State Management: StatefulWidget
- Network Library: http package
- Local Storage: shared_preferences

### 3. **Database (MySQL)**
- 3 Tabel utama: users, resources, purchases
- Relasi foreign key untuk data integrity

---

## Setup Database

### Prasyarat
- MySQL Server berjalan di localhost:3306
- Database baru bernama `honkai_star_retail`

### Langkah Setup
```bash
# 1. Login ke MySQL
mysql -u root -p

# 2. Buat database
CREATE DATABASE honkai_star_retail;
USE honkai_star_retail;

# 3. Jalankan script SQL
SOURCE backend/database.sql;
```

### Data Awal
Script SQL akan membuat:
- **Users**: 
  - Admin: email: `admin@honkai.com`, password: `admin123456` (hashed)
  - User: email: `user@honkai.com`, password: `user1234567` (hashed)
  
- **Resources**: 
  - Stellar Jade (Currency)
  - Oneiric Shards (Currency)
  - Parthian Shot (Light Cone)
  - Dance at Twilight (Light Cone)
  - Before the Tutorial Mission Starts (Light Cone)
  - Cosmic Dust (Material)

---

## Setup Backend

### 1. Instalasi Dependencies
```bash
cd backend
npm install
```

### 2. Konfigurasi Environment
Edit file `.env`:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=honkai_star_retail
DB_PORT=3306
PORT=5000
JWT_SECRET=honkai_star_retail_secret_key_2024_ultra_secure_token_alphanumeric
FRONTEND_URL=http://localhost:19100
```

### 3. Jalankan Server
```bash
# Production
npm start

# Development (dengan auto-reload)
npm run dev
```

Server akan berjalan di: `http://localhost:5000`

---

## API Endpoints

### Authentication Endpoints

#### Register User
```
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "username",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}

Response:
{
  "message": "Registrasi berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "username",
    "role": "user"
  }
}
```

#### Login User
```
POST /auth/login
Content-Type: application/json

{
  "email": "user@honkai.com",
  "password": "user1234567"
}

Response:
{
  "message": "Login berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 2,
    "email": "user@honkai.com",
    "username": "user",
    "role": "user",
    "firstName": "User",
    "lastName": "Honkai",
    "avatarUrl": null
  }
}
```

#### Verify Token
```
GET /auth/verify
Authorization: Bearer {token}

Response:
{
  "user": {
    "id": 1,
    "email": "admin@honkai.com",
    "username": "admin",
    "role": "admin",
    "firstName": "Admin",
    "lastName": "Honkai",
    "avatarUrl": null
  }
}
```

### Resources (Products) Endpoints

#### Get All Resources (Filter by Type)
```
GET /resources
GET /resources?type=Currency
GET /resources?type=Light%20Cone
GET /resources?type=Material

Response:
[
  {
    "id": 1,
    "name": "Stellar Jade",
    "type": "Currency",
    "description": "Premium currency...",
    "stock": 1000,
    "image_url": "https://...",
    "price": 9.99,
    "created_at": "2024-01-01T10:00:00Z",
    "updated_at": "2024-01-01T10:00:00Z"
  },
  ...
]
```

#### Get Single Resource
```
GET /resources/{id}

Response:
{
  "id": 1,
  "name": "Stellar Jade",
  "type": "Currency",
  "description": "Premium currency untuk membeli Light Cone dan Items",
  "stock": 1000,
  "image_url": "https://...",
  "price": 9.99,
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-01T10:00:00Z"
}
```

#### Create Resource (Admin Only)
```
POST /resources
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "New Resource",
  "type": "Currency",
  "description": "Description here",
  "stock": 100,
  "imageUrl": "https://...",
  "price": 9.99
}

Response:
{
  "message": "Resource berhasil ditambahkan",
  "id": 7
}
```

#### Update Resource (Admin Only)
```
PUT /resources/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Updated Resource",
  "type": "Light Cone",
  "description": "Updated description",
  "stock": 150,
  "imageUrl": "https://...",
  "price": 14.99
}

Response:
{
  "message": "Resource berhasil diperbarui"
}
```

#### Delete Resource (Admin Only)
```
DELETE /resources/{id}
Authorization: Bearer {token}

Response:
{
  "message": "Resource berhasil dihapus"
}
```

### Purchases Endpoints

#### Create Purchase
```
POST /purchases
Authorization: Bearer {token}
Content-Type: application/json

{
  "resourceId": 1,
  "quantity": 5
}

Response:
{
  "message": "Pembelian berhasil",
  "purchaseId": 1
}
```

#### Get Purchase History
```
GET /purchases/history
Authorization: Bearer {token}

Response:
[
  {
    "id": 1,
    "user_id": 2,
    "resource_id": 1,
    "name": "Stellar Jade",
    "type": "Currency",
    "quantity": 5,
    "total_price": 49.95,
    "price": 9.99,
    "image_url": "https://...",
    "purchase_date": "2024-01-02T15:30:00Z"
  },
  ...
]
```

---

## Setup Frontend (Flutter)

### 1. Instalasi Dependencies
```bash
flutter pub get
```

### 2. Konfigurasi API URL
Edit `lib/services/auth_service.dart`, `lib/services/resource_service.dart`, dan `lib/services/purchase_service.dart`:
```dart
static const String baseUrl = 'http://localhost:5000'; // ubah IP jika diperlukan
```

### 3. Jalankan Aplikasi

#### Untuk emulator/device
```bash
flutter run

# Specific device
flutter run -d <device_id>
```

#### Untuk web
```bash
flutter run -d chrome
```

---

## UI Design & Customization

### Tema Warna

Aplikasi menggunakan palet warna tema luar angkasa dengan customization pada:

1. **Background Color**
   - Primary: `#0A0E27` (Dark Blue Purple)
   - Secondary: `#1A1B3E` (Deep Purple)
   - Tertiary: `#2D1B4E` (Dark Purple)

2. **Text Color**
   - Primary: `#FFFFFF` (White)
   - Secondary: `#E8E8E8` (Silver)
   - Tertiary: `#A8A8A8` (Light Gray)

3. **Accent Color**
   - Bright Blue: `#00D4FF` (untuk tombol dan highlight)
   - Neon Purple: `#9D4EDD` (untuk secondary accent)

4. **Status Color**
   - Success: `#2ECC71` (Hijau)
   - Error: `#E74C3C` (Merah)
   - Warning: `#F39C12` (Kuning)

### Component Styling

Semua komponen menggunakan border-radius 12px untuk tampilan modern:
- TextField
- Button
- Card
- Dialog

### Font Family
- Primary: Roboto

### Font Size Hierarchy
- Display Large: 32px (judul halaman)
- Display Medium: 28px (subtitle)
- Headline: 20-24px
- Title: 16-18px
- Body: 14-16px
- Label: 11-14px

---

## Fitur Utama

### 1. Authentication
- ✅ Login dengan email & password
- ✅ Register akun baru
- ✅ JWT Bearer Token (20+ karakter, alphanumeric)
- ✅ Token verification di protected endpoints
- 🔄 Google OAuth (implementasi siap, perlu Google Client ID)

### 2. User Features
- ✅ Melihat katalog produk
- ✅ Filter produk berdasarkan kategori
- ✅ Pencarian produk
- ✅ Melihat detail produk
- ✅ Membeli produk dengan quantity selectable
- ✅ Melihat riwayat pembelian
- ✅ Melihat profil user

### 3. Admin Features
- ✅ Menambah produk baru
- ✅ Mengubah data produk
- ✅ Menghapus produk
- ✅ Melihat stok produk

---

## Validasi Data

### 1. Registration Form
- ✅ Email validation (harus mengandung @)
- ✅ Username validation (tidak boleh kosong)
- ✅ Password validation (minimal 8 karakter)
- ✅ Password confirmation (harus sama)

### 2. Login Form
- ✅ Email validation (harus mengandung @)
- ✅ Password validation (minimal 8 karakter)

### 3. Admin Product Form
- ✅ Nama produk (tidak boleh kosong)
- ✅ Tipe produk (tidak boleh kosong)
- ✅ Stok (harus berupa angka positif)
- ✅ Harga (harus berupa angka positif)

### 4. Purchase Validation
- ✅ Quantity harus positif
- ✅ Stock harus cukup
- ✅ Bearer token harus valid

---

## Halaman Aplikasi

### 1. Login Screen
- Email input field
- Password input field
- Login button
- Google login button (placeholder)
- Register link

### 2. Register Screen
- Email input field
- Username input field
- First Name input field (optional)
- Last Name input field (optional)
- Password input field
- Confirm password input field
- Register button
- Login link

### 3. Home Screen (Katalog Produk)
- Search bar untuk mencari produk
- Category filter (Semua, Currency, Light Cone, Material)
- Grid display produk (2 kolom)
- Floating Action Button untuk admin (tambah produk)
- Refresh indicator untuk reload data

### 4. Product Detail Screen
- Gambar produk (large)
- Nama produk
- Tipe produk
- Deskripsi lengkap
- Stok tersedia
- Harga
- **User view**: Quantity controller + tombol Beli
- **Admin view**: Tombol Edit Data + Tombol Hapus Barang (merah)

### 5. Admin Form Screen (Tambah/Ubah)
- Nama produk input
- Tipe produk input
- Deskripsi input (multi-line)
- Stok input (number)
- Harga input (number)
- URL Gambar input
- Preview gambar
- Tombol Simpan / Simpan Perubahan
- Tombol Batal

### 6. Profile Screen
- Avatar (circular)
- Username
- Role badge (User/Admin)
- Informasi akun (Email, Nama Lengkap)
- Kunci keamanan / Token display
- Riwayat pembelian (table/list)
- Tombol Keluar

---

## Fitur Kreativitas

### 1. Space Theme
Aplikasi menggunakan tema luar angkasa dengan palet warna biru tua keunguan yang konsisten di semua halaman

### 2. Dynamic Admin Controls
- Floating action button yang hanya muncul untuk admin
- Conditional rendering pada product detail screen antara user dan admin

### 3. Real-time Validation
- Validasi real-time pada form dengan error messages yang jelas
- Visual feedback untuk status (success, error, warning)

### 4. Purchase History Tracking
- User dapat melihat semua riwayat pembelian dengan detail lengkap
- Tanggal transaksi, nama produk, tipe, quantity, dan harga

### 5. Token-based Security
- Bearer token dengan panjang 64 karakter alphanumeric
- Token verification di setiap protected endpoint
- JWT dengan expiry 7 hari

---

## Testing Credentials

### Admin Account
- Email: `admin@honkai.com`
- Password: `admin123456`

### User Account
- Email: `user@honkai.com`
- Password: `user1234567`

---

## Troubleshooting

### 1. Backend Connection Error
- Pastikan server Node.js berjalan di port 5000
- Cek IP address di config file sesuai dengan network setup

### 2. Database Connection Error
- Pastikan MySQL server berjalan
- Verifikasi credentials di .env file
- Pastikan database `honkai_star_retail` sudah dibuat

### 3. Flutter App Crash
- Jalankan `flutter clean` dan `flutter pub get`
- Restart emulator/device
- Cek port yang digunakan tidak konflik

### 4. Token Invalid Error
- Silakan login ulang
- Token tersimpan di SharedPreferences
- Pastikan backend JWT_SECRET sama di .env

---

## Dependencies

### Backend
- express 4.18.2
- mysql2 3.6.0
- jsonwebtoken 9.1.0
- bcryptjs 2.4.3
- cors 2.8.5
- dotenv 16.3.1

### Frontend
- http 1.1.0
- shared_preferences 2.2.0
- google_sign_in 6.1.0
- flutter_svg 2.0.0
- intl 0.19.0

---

## Future Enhancements

1. Google OAuth full implementation
2. Payment gateway integration
3. Notification system
4. Product rating & review
5. Wishlist feature
6. Multiple language support
7. Dark mode toggle
8. Analytics dashboard untuk admin

---

**Terakhir diupdate**: 01 Juni 2026
**Versi**: 1.0.0
