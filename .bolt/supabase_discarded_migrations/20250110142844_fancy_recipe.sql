-- Create admin user
INSERT INTO users (
  id,
  email,
  password,
  full_name,
  created_at
) VALUES (
  UUID(),
  'admin@admin.com',
  PASSWORD('admin123'),
  'Admin User',
  NOW()
);

-- Get the inserted user's ID
SET @admin_id = LAST_INSERT_ID();

-- Make sure admin role exists
INSERT IGNORE INTO roles (name, description)
VALUES ('admin', 'Administrator with full access');

-- Get the admin role ID
SET @admin_role_id = (SELECT id FROM roles WHERE name = 'admin');

-- Assign admin role to user
INSERT INTO user_roles (
  id,
  user_id,
  role_id,
  created_at
) VALUES (
  UUID(),
  @admin_id,
  @admin_role_id,
  NOW()
);