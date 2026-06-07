# Backend API Setup Guide

## Quick Start

### 1. Prerequisites
- Node.js v14 atau lebih tinggi
- MySQL Server running
- npm atau yarn

### 2. Installation

```bash
cd backend
npm install
```

### 3. Database Setup

```bash
# Buka MySQL terminal
mysql -u root -p

# Jalankan SQL script
CREATE DATABASE honkai_star_retail;
USE honkai_star_retail;
SOURCE backend/database.sql;
```

### 4. Environment Configuration

Buat atau edit file `.env` di folder backend:

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=honkai_star_retail
DB_PORT=3306
PORT=5000
NODE_ENV=development
JWT_SECRET=honkai_star_retail_secret_key_2024_ultra_secure_token_alphanumeric
SESSION_SECRET=your_session_secret

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:5000/auth/google/callback

# Facebook OAuth Configuration
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
FACEBOOK_CALLBACK_URL=http://localhost:5000/auth/facebook/callback

# Twitter OAuth Configuration
TWITTER_CONSUMER_KEY=your_twitter_consumer_key
TWITTER_CONSUMER_SECRET=your_twitter_consumer_secret
TWITTER_CALLBACK_URL=http://localhost:5000/auth/twitter/callback

FRONTEND_URL=http://localhost:19100
```

### 5. Running Server

```bash
# Development dengan auto-reload
npm run dev

# Production
npm start
```

Server akan berjalan di `http://localhost:5000`

## API Response Format

Semua response menggunakan JSON format dengan status code HTTP:

### Success Response (2xx)
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

### Error Response (4xx, 5xx)
```json
{
  "success": false,
  "error": "Error message"
}
```

## Bearer Token

Token format JWT yang diproduksi oleh backend:
- Length: 64+ characters
- Type: Alphanumeric
- Format: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- Expiry: 7 days

Gunakan token dengan menambahkan ke header:
```
Authorization: Bearer {token}
```

## OAuth External Authentication

Backend mendukung login eksternal menggunakan Google, Facebook, dan Twitter.
- Google: `/auth/google`
- Facebook: `/auth/facebook`
- Twitter: `/auth/twitter`

Callback endpoint menerima login OAuth lalu mengembalikan JSON berisi token dan data user.

## Database Schema

### Users Table
- id (INT, Primary Key)
- email (VARCHAR 255, UNIQUE)
- username (VARCHAR 100, UNIQUE)
- password (VARCHAR 255, hashed)
- role (ENUM: 'user', 'admin')
- first_name (VARCHAR 100)
- last_name (VARCHAR 100)
- avatar_url (VARCHAR 500)
- google_id (VARCHAR 255)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### Resources Table
- id (INT, Primary Key)
- name (VARCHAR 200)
- type (VARCHAR 100)
- description (TEXT)
- stock (INT)
- image_url (VARCHAR 500)
- price (DECIMAL 10,2)
- created_by (INT, Foreign Key)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

### Purchases Table
- id (INT, Primary Key)
- user_id (INT, Foreign Key)
- resource_id (INT, Foreign Key)
- quantity (INT)
- total_price (DECIMAL 10,2)
- purchase_date (TIMESTAMP)
