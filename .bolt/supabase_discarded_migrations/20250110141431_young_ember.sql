-- Create admin user
INSERT INTO users (
    id,
    email,
    password,
    full_name,
    created_at,
    updated_at
) VALUES (
    UUID(),
    'admin@admin.com',
    PASSWORD('admin123'),
    'Admin User',
    NOW(),
    NOW()
);

-- Get the user ID we just created
SET @admin_id = LAST_INSERT_ID();

-- Get admin role ID
SELECT @role_id := id FROM roles WHERE name = 'admin';

-- Assign admin role to user
INSERT INTO user_roles (
    id,
    user_id,
    role_id,
    created_at
) VALUES (
    UUID(),
    @admin_id,
    @role_id,
    NOW()
);