-- ═══════════════════════════════════════════════════════════════════
-- Home Ideator — MySQL Init Schema
-- Runs automatically when the mysql container first starts.
-- ═══════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS home_ideator;
CREATE DATABASE IF NOT EXISTS home_ideator_test;

USE home_ideator;

-- ── Admin accounts ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(100) UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('admin','end_user_admin','ml_user') NOT NULL DEFAULT 'end_user_admin',
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ── End users (Flutter app users) ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS end_users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    uid           VARCHAR(36) UNIQUE NOT NULL,
    username      VARCHAR(100) UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ── Products / shop components ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    category      VARCHAR(100),
    cost          DECIMAL(10,2) DEFAULT 0.00,
    discount_pct  INT DEFAULT 0,
    rating        DECIMAL(3,2) DEFAULT 0.00,
    ecom          VARCHAR(100),
    ecom_logo     TEXT,
    image_url     TEXT,
    website_url   TEXT,
    in_stock      BOOLEAN DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ── Device registry ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_devices (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    device_id     VARCHAR(100) UNIQUE NOT NULL,
    user_uid      VARCHAR(36) NOT NULL,
    product_id    INT,
    device_name   VARCHAR(255),
    device_type   VARCHAR(100),
    website_url   TEXT,
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_uid)   REFERENCES end_users(uid)  ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)    ON DELETE SET NULL
);

-- ── Seed: superadmin account (password = Admin@1234) ─────────────────
-- bcrypt hash of "Admin@1234"
INSERT IGNORE INTO admin_users (username, email, password_hash, role) VALUES
  ('superadmin', 'admin@homeideator.com',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGpFMD9TjEu2lKq5KMEcV9yEXH2', 'admin');

-- ── Seed: end_user_admin (password = Admin@1234) ─────────────────────
INSERT IGNORE INTO admin_users (username, email, password_hash, role) VALUES
  ('euadmin', 'euadmin@homeideator.com',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGpFMD9TjEu2lKq5KMEcV9yEXH2', 'end_user_admin');

-- ── Seed: ml_user (password = Admin@1234) ────────────────────────────
INSERT IGNORE INTO admin_users (username, email, password_hash, role) VALUES
  ('mluser', 'mluser@homeideator.com',
   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGpFMD9TjEu2lKq5KMEcV9yEXH2', 'ml_user');

-- ════════════════════════════════════════════════════════════════════
-- Mirror schema into test database
-- ════════════════════════════════════════════════════════════════════
USE home_ideator_test;

CREATE TABLE IF NOT EXISTS admin_users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(100) UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('admin','end_user_admin','ml_user') NOT NULL DEFAULT 'end_user_admin',
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS end_users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    uid           VARCHAR(36) UNIQUE NOT NULL,
    username      VARCHAR(100) UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL,
    category      VARCHAR(100),
    cost          DECIMAL(10,2) DEFAULT 0.00,
    discount_pct  INT DEFAULT 0,
    rating        DECIMAL(3,2) DEFAULT 0.00,
    ecom          VARCHAR(100),
    ecom_logo     TEXT,
    image_url     TEXT,
    website_url   TEXT,
    in_stock      BOOLEAN DEFAULT TRUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_devices (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    device_id     VARCHAR(100) UNIQUE NOT NULL,
    user_uid      VARCHAR(36) NOT NULL,
    product_id    INT,
    device_name   VARCHAR(255),
    device_type   VARCHAR(100),
    website_url   TEXT,
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_uid)   REFERENCES end_users(uid)  ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)    ON DELETE SET NULL
);

-- Seed test admins (same hashes)
INSERT IGNORE INTO admin_users (username, email, password_hash, role) VALUES
  ('admin_test',   'admin@test.com',   '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGpFMD9TjEu2lKq5KMEcV9yEXH2', 'admin'),
  ('euadmin_test', 'euadmin@test.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGpFMD9TjEu2lKq5KMEcV9yEXH2', 'end_user_admin'),
  ('mluser_test',  'mluser@test.com',  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TiGpFMD9TjEu2lKq5KMEcV9yEXH2', 'ml_user');
