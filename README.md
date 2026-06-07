# Honkai Star Retail - E-Commerce Application

**Version**: 1.0.0  
**Last Updated**: June 2024

## 📱 Overview

Honkai Star Retail adalah aplikasi e-commerce mobile yang menyediakan galactic resources dan light cones untuk game Honkai Star Rail. Aplikasi ini dibangun dengan tech stack modern: **Flutter** (Frontend), **Node.js/Express** (Backend), dan **MySQL** (Database).

### Fitur Utama
- ✅ User Authentication (Email/Password + Google OAuth)
- ✅ Product Catalog dengan Search & Filter
- ✅ Shopping Cart & Purchase History
- ✅ Admin Dashboard untuk CRUD Products
- ✅ JWT Bearer Token Security
- ✅ Space-themed UI Design

## 🚀 Quick Start

### Backend Setup
```bash
cd backend
npm install
npm run dev  # Runs on http://localhost:5000
```

### Frontend Setup
```bash
flutter pub get
flutter run
```

### Database Setup
```bash
mysql -u root -p
CREATE DATABASE honkai_star_retail;
USE honkai_star_retail;
SOURCE backend/database.sql;
```

## 📋 Requirements Completed

### ✅ Database (MySQL)
- Create, Retrieve, Update, Delete operations
- 3 tables: users, resources, purchases

### ✅ Frontend (Flutter Mobile App)
- **12+ UI Components**: TextField, Buttons (3 types), Card, GridView, ListView, Dialog, FAB, FilterChip, Progress Indicator
- **6 Pages**: Login, Register, Catalog, Product Detail, Admin Form, Profile
- **3+ Validations**: Email, Password, Numeric inputs

### ✅ Backend (Node.js, Express)
- **3+ GET endpoints**: /resources, /resources/:id, /purchases/history
- **4 CRUD endpoints**: POST, PUT, DELETE operations
- **Bearer Token Verification**: Protected endpoints

### ✅ Authentication
- Email/Password login & registration
- Google OAuth ready
- JWT Bearer tokens (64+ chars)

### ✅ UI Design
- Space-themed: Dark blue-purple (#0A0E27, #1A1B3E)
- Customized properties: Font, Colors, Sizing, Border Radius
- Visible customizations in app
- Proper contrast & usability

### ✅ Documentation
- `DOCUMENTATION.md` - Complete guide
- `README_FLUTTER.md` - Frontend guide
- `README_BACKEND.md` - Backend guide

## 🧪 Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@honkai.com | admin123456 |
| User | user@honkai.com | user1234567 |

## 📚 Documentation

- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Complete API & feature documentation
- **[README_FLUTTER.md](README_FLUTTER.md)** - Flutter frontend setup guide
- **[README_BACKEND.md](README_BACKEND.md)** - Node.js backend setup guide

## 🎨 Color Theme

| Element | Color | Hex |
|---------|-------|-----|
| Background | Dark Blue Purple | #0A0E27 |
| Secondary | Deep Purple | #1A1B3E |
| Accent | Bright Blue | #00D4FF |
| Text | White | #FFFFFF |

## 📦 Tech Stack

- **Frontend**: Flutter/Dart
- **Backend**: Node.js/Express
- **Database**: MySQL
- **Authentication**: JWT + Google OAuth
- **State Management**: StatefulWidget
- **HTTP Client**: http package

## 🚀 Deployment

See respective README files for deployment instructions.

---

**For detailed information, please refer to DOCUMENTATION.md**
