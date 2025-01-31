-- Function to generate unique ID
DELIMITER $$
CREATE FUNCTION generate_id() 
RETURNS CHAR(36)
DETERMINISTIC
BEGIN
    SET @id = CONCAT(
        HEX(UNIX_TIMESTAMP()),
        HEX(FLOOR(RAND() * 4294967295)),
        HEX(CONNECTION_ID()),
        HEX(FLOOR(RAND() * 4294967295))
    );
    RETURN INSERT(@id, 9, 0, '-');
END$$
DELIMITER ;

-- Create roles table
CREATE TABLE roles (
    id CHAR(36) NOT NULL,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert roles with unique IDs
INSERT INTO roles (id, name, description) VALUES 
(generate_id(), 'admin', 'Administrator with full access'),
(generate_id(), 'sales', 'Sales staff with POS access'),
(generate_id(), 'referee', 'Referee with referral tracking');

-- Create users table
CREATE TABLE users (
    id CHAR(36) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    auth_token VARCHAR(255) DEFAULT NULL,
    token_expires TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert users with unique IDs and proper password hashing
INSERT INTO users (id, email, password, full_name) VALUES
(generate_id(), 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin User'),
(generate_id(), 'sales@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sales User'),
(generate_id(), 'referee@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Referee User');

-- Create user_roles table
CREATE TABLE user_roles (
    id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    role_id CHAR(36) NOT NULL,
    branch_id CHAR(36) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY unique_user_role (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Assign roles to users
INSERT INTO user_roles (id, user_id, role_id)
SELECT 
    generate_id(),
    u.id,
    r.id
FROM users u
JOIN roles r ON 
    CASE 
        WHEN u.email = 'admin@example.com' THEN r.name = 'admin'
        WHEN u.email = 'sales@example.com' THEN r.name = 'sales'
        WHEN u.email = 'referee@example.com' THEN r.name = 'referee'
    END;