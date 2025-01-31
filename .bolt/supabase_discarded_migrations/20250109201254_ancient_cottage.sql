-- Create roles table
CREATE TABLE roles (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create users table
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create user_roles table
CREATE TABLE user_roles (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    role_id CHAR(36),
    branch_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create branches table
CREATE TABLE branches (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    is_ecommerce_base BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create products table
CREATE TABLE products (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 0,
    photo_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create product_properties table
CREATE TABLE product_properties (
    id CHAR(36) PRIMARY KEY,
    product_id CHAR(36) UNIQUE,
    ingredients JSON,
    dosage TEXT,
    storage_instructions TEXT,
    usage_instructions TEXT,
    warnings JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create settings table
CREATE TABLE settings (
    id CHAR(36) PRIMARY KEY,
    `key` VARCHAR(50) UNIQUE NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Create sales table
CREATE TABLE sales (
    id CHAR(36) PRIMARY KEY,
    total DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'card') NOT NULL,
    customer_id CHAR(36),
    admin_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- Create sale_items table
CREATE TABLE sale_items (
    id CHAR(36) PRIMARY KEY,
    sale_id CHAR(36),
    product_id CHAR(36),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- Create inventory_adjustments table
CREATE TABLE inventory_adjustments (
    id CHAR(36) PRIMARY KEY,
    product_id CHAR(36),
    quantity_change INT NOT NULL,
    reason TEXT,
    admin_id CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (admin_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- Create inventory_transfers table
CREATE TABLE inventory_transfers (
    id CHAR(36) PRIMARY KEY,
    product_id CHAR(36),
    from_branch_id CHAR(36),
    to_branch_id CHAR(36),
    quantity INT NOT NULL,
    status ENUM('pending', 'in_transit', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (from_branch_id) REFERENCES branches(id),
    FOREIGN KEY (to_branch_id) REFERENCES branches(id)
) ENGINE=InnoDB;

-- Create online_orders table
CREATE TABLE online_orders (
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
CREATE TABLE online_order_items (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36),
    product_id CHAR(36),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES online_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

-- Create referral_earnings table
CREATE TABLE referral_earnings (
    id CHAR(36) PRIMARY KEY,
    referee_id CHAR(36),
    order_id CHAR(36),
    amount DECIMAL(10,2) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (referee_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES online_orders(id)
) ENGINE=InnoDB;

-- Create indexes
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_inventory_transfers_product ON inventory_transfers(product_id);
CREATE INDEX idx_inventory_transfers_from_branch ON inventory_transfers(from_branch_id);
CREATE INDEX idx_inventory_transfers_to_branch ON inventory_transfers(to_branch_id);
CREATE INDEX idx_online_orders_status ON online_orders(status);
CREATE INDEX idx_referral_earnings_referee ON referral_earnings(referee_id);

-- Insert default settings
INSERT INTO settings (`key`, value) VALUES
('vat_percentage', 5),
('referral_percentage', 2),
('maintenance_percentage', 1);

-- Insert default roles
INSERT INTO roles (id, name, description) VALUES
(UUID(), 'admin', 'Administrator with full access'),
(UUID(), 'sales', 'Sales staff with POS access'),
(UUID(), 'referee', 'Referee with referral tracking');