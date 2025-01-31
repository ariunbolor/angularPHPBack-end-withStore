-- Create branches table first
CREATE TABLE IF NOT EXISTS branches (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  is_ecommerce_base BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create inventory_transfers table with proper foreign keys
CREATE TABLE IF NOT EXISTS inventory_transfers (
  id CHAR(36) PRIMARY KEY,
  product_id CHAR(36),
  from_branch_id CHAR(36),
  to_branch_id CHAR(36),
  quantity INT NOT NULL,
  status ENUM('pending', 'in_transit', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (from_branch_id) REFERENCES branches(id) ON DELETE RESTRICT,
  FOREIGN KEY (to_branch_id) REFERENCES branches(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Create indexes for better performance
CREATE INDEX idx_inventory_transfers_product ON inventory_transfers(product_id);
CREATE INDEX idx_inventory_transfers_from_branch ON inventory_transfers(from_branch_id);
CREATE INDEX idx_inventory_transfers_to_branch ON inventory_transfers(to_branch_id);
CREATE INDEX idx_inventory_transfers_status ON inventory_transfers(status);