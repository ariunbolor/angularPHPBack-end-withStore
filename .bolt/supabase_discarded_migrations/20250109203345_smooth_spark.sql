-- Create roles
INSERT INTO roles (id, name, description) VALUES
(UUID(), 'admin', 'Administrator with full access'),
(UUID(), 'sales', 'Sales staff with POS access'),
(UUID(), 'referee', 'Referee with referral tracking');

-- Create users with hashed passwords (password is 'password123' for all users)
INSERT INTO users (id, email, password, full_name) VALUES
(UUID(), 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin User'),
(UUID(), 'sales@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sales User'),
(UUID(), 'referee@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Referee User');

-- Assign roles to users
INSERT INTO user_roles (id, user_id, role_id) 
SELECT UUID(), u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE u.email = 'admin@example.com' AND r.name = 'admin'
UNION ALL
SELECT UUID(), u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE u.email = 'sales@example.com' AND r.name = 'sales'
UNION ALL
SELECT UUID(), u.id, r.id
FROM users u
CROSS JOIN roles r
WHERE u.email = 'referee@example.com' AND r.name = 'referee';

-- Create branches
INSERT INTO branches (id, name, location, is_ecommerce_base) VALUES
(UUID(), 'Main Branch', 'Main Street', true),
(UUID(), 'North Branch', 'North Avenue', false),
(UUID(), 'South Branch', 'South Road', false);

-- Create products
INSERT INTO products (id, name, sku, description, price, quantity, photo_url) VALUES
(UUID(), 'Vitamin C 1000mg', 'VIT-C1000', 'High-potency vitamin C supplement', 19.99, 100, 'https://example.com/vitc.jpg'),
(UUID(), 'Omega-3 Fish Oil', 'OMEGA3', 'Premium fish oil supplement', 24.99, 75, 'https://example.com/omega3.jpg'),
(UUID(), 'Magnesium Complex', 'MAG500', 'High absorption magnesium blend', 18.99, 50, 'https://example.com/magnesium.jpg'),
(UUID(), 'Multivitamin Plus', 'MULTI100', 'Complete daily multivitamin', 29.99, 200, 'https://example.com/multivitamin.jpg'),
(UUID(), 'Protein Powder', 'PROT500', 'Whey protein isolate', 39.99, 30, 'https://example.com/protein.jpg');

-- Create product properties
INSERT INTO product_properties (id, product_id, ingredients, dosage, storage_instructions, usage_instructions, warnings)
SELECT 
  UUID(),
  p.id,
  '["Vitamin C (Ascorbic Acid)", "Citrus Bioflavonoids"]',
  '1 tablet daily with food',
  'Store in a cool, dry place',
  'Take one tablet daily with a meal',
  '["Consult physician if pregnant", "Keep out of reach of children"]'
FROM products p
WHERE p.sku = 'VIT-C1000';

INSERT INTO product_properties (id, product_id, ingredients, dosage, storage_instructions, usage_instructions, warnings)
SELECT 
  UUID(),
  p.id,
  '["Fish Oil", "EPA", "DHA"]',
  '2 softgels daily',
  'Store in a cool, dry place',
  'Take with meals',
  '["Contains fish", "Consult physician if on blood thinners"]'
FROM products p
WHERE p.sku = 'OMEGA3';

-- Create settings
INSERT INTO settings (id, `key`, value) VALUES
(UUID(), 'vat_percentage', 5),
(UUID(), 'referral_percentage', 2),
(UUID(), 'maintenance_percentage', 1);

-- Create branch inventory
INSERT INTO branch_inventory (branch_id, product_id, quantity, min_quantity, max_quantity)
SELECT 
  b.id,
  p.id,
  FLOOR(RAND() * 100),
  10,
  100
FROM branches b
CROSS JOIN products p;

-- Create some customers
INSERT INTO customers (id, name, email, phone, address) VALUES
(UUID(), 'John Doe', 'john@example.com', '1234567890', '123 Main St'),
(UUID(), 'Jane Smith', 'jane@example.com', '0987654321', '456 Oak Ave'),
(UUID(), 'Bob Wilson', 'bob@example.com', '5555555555', '789 Pine Rd');

-- Create some POS transactions
INSERT INTO pos_transactions (id, branch_id, customer_id, total_amount, vat_amount, payment_method, status)
SELECT 
  UUID(),
  b.id,
  c.id,
  ROUND(RAND() * 1000, 2),
  ROUND(RAND() * 50, 2),
  CASE WHEN RAND() > 0.5 THEN 'cash' ELSE 'card' END,
  'completed'
FROM branches b
CROSS JOIN customers c
LIMIT 10;

-- Create transaction items
INSERT INTO pos_transaction_items (id, transaction_id, product_id, quantity, price)
SELECT 
  UUID(),
  t.id,
  p.id,
  FLOOR(RAND() * 5) + 1,
  p.price
FROM pos_transactions t
CROSS JOIN products p
LIMIT 20;

-- Create some referral earnings
INSERT INTO referral_earnings (id, referee_id, transaction_id, amount, percentage)
SELECT 
  UUID(),
  u.id,
  t.id,
  ROUND(t.total_amount * 0.02, 2),
  2
FROM users u
CROSS JOIN pos_transactions t
WHERE u.email = 'referee@example.com'
LIMIT 5;