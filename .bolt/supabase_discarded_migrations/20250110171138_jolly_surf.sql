-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  parent_id CHAR(36),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add category_id to products if not exists
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS category_id CHAR(36),
ADD CONSTRAINT fk_product_category 
FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- Insert sample categories
INSERT INTO categories (id, name, description) VALUES
(UUID(), 'Vitamins & Supplements', 'Essential vitamins and dietary supplements'),
(UUID(), 'Pain Relief', 'Pain relief medications and treatments'),
(UUID(), 'First Aid', 'First aid supplies and equipment'),
(UUID(), 'Personal Care', 'Personal care and hygiene products'),
(UUID(), 'Health Foods', 'Healthy food products and supplements');