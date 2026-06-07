-- Database: honkai_star_retail

-- Users Table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255),
  role ENUM('user', 'admin') DEFAULT 'user',
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  avatar_url LONGTEXT,
  google_id VARCHAR(255),
  facebook_id VARCHAR(255),
  twitter_id VARCHAR(255),
  oauth_provider VARCHAR(50),
  oauth_id VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Resources/Products Table
CREATE TABLE IF NOT EXISTS resources (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  type VARCHAR(100) NOT NULL,
  description TEXT,
  stock INT NOT NULL,
  image_url VARCHAR(500),
  price DECIMAL(10, 2) NOT NULL,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Purchases Table (Transaction History)
CREATE TABLE IF NOT EXISTS purchases (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  resource_id INT NOT NULL,
  quantity INT NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (resource_id) REFERENCES resources(id)
);

-- Insert sample data
INSERT INTO users (email, username, password, role, first_name, last_name) VALUES 
('admin@honkai.com', 'admin', '$2a$10$E8DLAUDhXxXWPT2lBG8e7.G.nqB1x1vq7Qrg5xWqvKb0hXyFpIKmW', 'admin', 'Admin', 'Honkai'),
('user@honkai.com', 'user', '$2a$10$dXJ3SW6G7P50eS3EagHkJOb47xVFVKCf7Ei9m4vHYLhKNKGKu2qfe', 'user', 'User', 'Honkai');

INSERT INTO resources (name, type, description, stock, image_url, price, created_by) VALUES
('Stellar Jade', 'Currency', 'Premium currency untuk membeli Light Cone dan Items', 1000, 'https://via.placeholder.com/200?text=Stellar+Jade', 9.99, 1),
('Oneiric Shards', 'Currency', 'Currency untuk mendapatkan discount', 500, 'https://via.placeholder.com/200?text=Oneiric+Shards', 4.99, 1),
('Parthian Shot', 'Light Cone', 'Light Cone untuk karakter berbilang elemen', 50, 'https://via.placeholder.com/200?text=Parthian+Shot', 14.99, 1),
('Dance at Twilight', 'Light Cone', 'Light Cone yang meningkatkan damage Break', 45, 'https://via.placeholder.com/200?text=Dance+at+Twilight', 14.99, 1),
('Before the Tutorial Mission Starts', 'Light Cone', 'Light Cone awal pemain', 100, 'https://via.placeholder.com/200?text=Before+Tutorial', 2.99, 1),
('Cosmic Dust', 'Material', 'Material untuk upgrade skill karakter', 200, 'https://via.placeholder.com/200?text=Cosmic+Dust', 1.99, 1);
