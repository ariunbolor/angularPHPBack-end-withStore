-- Create branches table
CREATE TABLE IF NOT EXISTS branches (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    is_ecommerce_base BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add initial branch if not exists
INSERT IGNORE INTO branches (id, name, location, is_ecommerce_base) 
VALUES ('main-branch-001', 'Main Branch', 'Main Location', TRUE);