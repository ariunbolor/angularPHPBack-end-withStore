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
    SHA2('admin123', 256),
    'Admin User',
    NOW(),
    NOW()
);

-- Get the admin role ID
SET @admin_role_id = (SELECT id FROM roles WHERE name = 'admin');

-- Get the newly created user ID
SET @admin_user_id = (SELECT id FROM users WHERE email = 'admin@admin.com');

-- Assign admin role to user
INSERT INTO user_roles (
    id,
    user_id,
    role_id,
    created_at
) VALUES (
    UUID(),
    @admin_user_id,
    @admin_role_id,
    NOW()
);