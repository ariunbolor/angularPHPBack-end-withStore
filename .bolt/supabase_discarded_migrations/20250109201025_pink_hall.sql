/*
  # Complete API Schema for MySQL

  1. Authentication & Users
    - `admins` table for admin users
    - `admin_tokens` table for JWT management
    - `users` table for general users
    - `user_roles` table for role assignments
  
  2. Inventory Management
    - `products` table for product information
    - `inventory_adjustments` table for stock changes
    - `inventory_transfers` table for branch transfers
  
  3. Sales & Orders
    - `sales` table for POS sales
    - `sale_items` table for POS sale line items
    - `online_orders` table for web store orders
    - `online_order_items` table for web order line items
  
  4. Referral System
    - `referral_earnings` table for referee commissions
    - `referral_customers` table for customer-referee relationships
  
  5. Settings & Configuration
    - `settings` table for global settings
*/

-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
  id CHAR(36) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create admin_tokens table
CREATE TABLE IF NOT EXISTS admin_tokens (
  id CHAR(36) PRIMARY KEY,
  admin_id CHAR(36),
  token VARCHAR(255) NOT NULL,
  is_valid BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create user_roles table
CREATE TABLE IF NOT EXISTS user_roles (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36),
  role ENUM('admin', 'sales', 'referee') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  quantity INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create inventory_adjustments table
CREATE TABLE IF NOT EXISTS inventory_adjustments (
  id CHAR(36) PRIMARY KEY,
  product_id CHAR(36),
  quantity_change INT NOT NULL,
  reason TEXT,
  admin_id CHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (admin_id) REFERENCES admins(id)
) ENGINE=InnoDB;

-- Create inventory_transfers table
CREATE TABLE IF NOT EXISTS inventory_transfers (
  id CHAR(36) PRIMARY KEY,
  product_id CHAR(36),
  from_branch_id CHAR(36),
  to_branch_id CHAR(36),
  quantity INT NOT NULL CHECK (quantity > 0),
  status ENUM('pending', 'in_transit', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (from_branch_id) REFERENCES branches(id),
  FOREIGN KEY (to_branch_id) REFERENCES branches(id)
) ENGINE=InnoDB;

-- Create sales table
CREATE TABLE IF NOT EXISTS sales (
  id CHAR(36) PRIMARY KEY,
  total DECIMAL(10,2) NOT NULL,
  payment_method ENUM('cash', 'card') NOT NULL,
  customer_id CHAR(36),
  admin_id CHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (admin_id) REFERENCES admins(id)
) ENGINE=InnoDB;

-- Create sale_items table
CREATE TABLE IF NOT EXISTS sale_items (
  id CHAR(36) PRIMARY KEY,
  sale_id CHAR(36),
  product_id CHAR(36),
  quantity INT NOT NULL CHECK (quantity > 0),
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- Create online_orders table
CREATE TABLE IF NOT EXISTS online_orders (
  id CHAR(36) PRIMARY KEY,
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(255) NOT NULL,
  customer_phone VARCHAR(50),
  shipping_address TEXT NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  payment_method ENUM('card') NOT NULL,
  status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create online_order_items table
CREATE TABLE IF NOT EXISTS online_order_items (
  id CHAR(36) PRIMARY KEY,
  order_id CHAR(36),
  product_id CHAR(36),
  quantity INT NOT NULL CHECK (quantity > 0),
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES online_orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- Create referral_earnings table
CREATE TABLE IF NOT EXISTS referral_earnings (
  id CHAR(36) PRIMARY KEY,
  referee_id CHAR(36),
  order_id CHAR(36),
  amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  percentage DECIMAL(5,2) NOT NULL CHECK (percentage >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (referee_id) REFERENCES users(id),
  FOREIGN KEY (order_id) REFERENCES online_orders(id)
) ENGINE=InnoDB;

-- Create referral_customers table
CREATE TABLE IF NOT EXISTS referral_customers (
  id CHAR(36) PRIMARY KEY,
  customer_id CHAR(36),
  referee_id CHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_referral (customer_id, referee_id),
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (referee_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- Create settings table
CREATE TABLE IF NOT EXISTS settings (
  id CHAR(36) PRIMARY KEY,
  `key` VARCHAR(50) UNIQUE NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Insert default settings
INSERT INTO settings (`key`, value) VALUES
  ('vat_percentage', 5),
  ('referral_percentage', 2),
  ('maintenance_percentage', 1)
ON DUPLICATE KEY UPDATE value = VALUES(value);

-- Create indexes for better performance
CREATE INDEX idx_admin_tokens_admin ON admin_tokens(admin_id);
CREATE INDEX idx_admin_tokens_valid ON admin_tokens(is_valid);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_inventory_adjustments_product ON inventory_adjustments(product_id);
CREATE INDEX idx_inventory_transfers_product ON inventory_transfers(product_id);
CREATE INDEX idx_inventory_transfers_status ON inventory_transfers(status);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_admin ON sales(admin_id);
CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);
CREATE INDEX idx_online_orders_status ON online_orders(status);
CREATE INDEX idx_online_order_items_order ON online_order_items(order_id);
CREATE INDEX idx_online_order_items_product ON online_order_items(product_id);
CREATE INDEX idx_referral_earnings_referee ON referral_earnings(referee_id);
CREATE INDEX idx_referral_earnings_order ON referral_earnings(order_id);
CREATE INDEX idx_referral_customers_customer ON referral_customers(customer_id);
CREATE INDEX idx_referral_customers_referee ON referral_customers(referee_id);
CREATE INDEX idx_settings_key ON settings(`key`);