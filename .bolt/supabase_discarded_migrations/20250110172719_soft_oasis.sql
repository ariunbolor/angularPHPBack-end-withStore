-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id varchar(36) PRIMARY KEY,
  name varchar(255) NOT NULL,
  description text,
  parent_id varchar(36),
  created_at timestamp DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Create wishlists table
CREATE TABLE IF NOT EXISTS wishlists (
  id varchar(36) PRIMARY KEY,
  user_id varchar(36) NOT NULL,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES web_users(id) ON DELETE CASCADE
);

-- Create wishlist_items table
CREATE TABLE IF NOT EXISTS wishlist_items (
  id varchar(36) PRIMARY KEY,
  wishlist_id varchar(36) NOT NULL,
  product_id varchar(36) NOT NULL,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (wishlist_id) REFERENCES wishlists(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY unique_wishlist_product (wishlist_id, product_id)
);

-- Add category_id to products table
ALTER TABLE products ADD COLUMN category_id varchar(36);
ALTER TABLE products ADD FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;