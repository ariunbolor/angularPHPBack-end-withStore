/*
  # Complete API Schema

  1. Authentication & Users
    - `admins` table for admin users
    - `admin_tokens` table for JWT management
    - `users` table for general users
    - `user_roles` table for role assignments
  
  2. Inventory Management
    - `products` table for product information
    - `inventory_adjustments` table for stock changes
    - `inventory_transfers` table for branch transfers
  
  3. Sales & Orders
    - `sales` table for POS sales
    - `sale_items` table for POS sale line items
    - `online_orders` table for web store orders
    - `online_order_items` table for web order line items
  
  4. Referral System
    - `referral_earnings` table for referee commissions
    - `referral_customers` table for customer-referee relationships
  
  5. Settings & Configuration
    - `settings` table for global settings
*/

-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  full_name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create admin_tokens table
CREATE TABLE IF NOT EXISTS admin_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id uuid REFERENCES admins(id) ON DELETE CASCADE,
  token text NOT NULL,
  is_valid boolean DEFAULT true,
  expires_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  full_name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create user_roles table
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'sales', 'referee')),
  created_at timestamptz DEFAULT now()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  sku text UNIQUE NOT NULL,
  description text,
  price numeric NOT NULL DEFAULT 0,
  quantity integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create inventory_adjustments table
CREATE TABLE IF NOT EXISTS inventory_adjustments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity_change integer NOT NULL,
  reason text,
  admin_id uuid REFERENCES admins(id),
  created_at timestamptz DEFAULT now()
);

-- Create inventory_transfers table
CREATE TABLE IF NOT EXISTS inventory_transfers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  from_branch_id uuid REFERENCES branches(id),
  to_branch_id uuid REFERENCES branches(id),
  quantity integer NOT NULL CHECK (quantity > 0),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_transit', 'completed', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create sales table
CREATE TABLE IF NOT EXISTS sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  total numeric NOT NULL,
  payment_method text NOT NULL CHECK (payment_method IN ('cash', 'card')),
  customer_id uuid REFERENCES users(id),
  admin_id uuid REFERENCES admins(id),
  created_at timestamptz DEFAULT now()
);

-- Create sale_items table
CREATE TABLE IF NOT EXISTS sale_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid REFERENCES sales(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  quantity integer NOT NULL CHECK (quantity > 0),
  price numeric NOT NULL CHECK (price >= 0),
  created_at timestamptz DEFAULT now()
);

-- Create online_orders table
CREATE TABLE IF NOT EXISTS online_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_phone text,
  shipping_address text NOT NULL,
  total numeric NOT NULL,
  payment_method text NOT NULL CHECK (payment_method IN ('card')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create online_order_items table
CREATE TABLE IF NOT EXISTS online_order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES online_orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id),
  quantity integer NOT NULL CHECK (quantity > 0),
  price numeric NOT NULL CHECK (price >= 0),
  created_at timestamptz DEFAULT now()
);

-- Create referral_earnings table
CREATE TABLE IF NOT EXISTS referral_earnings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referee_id uuid REFERENCES users(id),
  order_id uuid REFERENCES online_orders(id),
  amount numeric NOT NULL CHECK (amount >= 0),
  percentage numeric NOT NULL CHECK (percentage >= 0),
  created_at timestamptz DEFAULT now()
);

-- Create referral_customers table
CREATE TABLE IF NOT EXISTS referral_customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES users(id),
  referee_id uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(customer_id, referee_id)
);

-- Create settings table
CREATE TABLE IF NOT EXISTS settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text UNIQUE NOT NULL,
  value numeric NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Insert default settings
INSERT INTO settings (key, value) VALUES
  ('vat_percentage', 5),
  ('referral_percentage', 2),
  ('maintenance_percentage', 1)
ON CONFLICT (key) DO NOTHING;

-- Enable RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE online_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE online_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX idx_admin_tokens_admin ON admin_tokens(admin_id);
CREATE INDEX idx_admin_tokens_valid ON admin_tokens(is_valid);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_inventory_adjustments_product ON inventory_adjustments(product_id);
CREATE INDEX idx_inventory_transfers_product ON inventory_transfers(product_id);
CREATE INDEX idx_inventory_transfers_status ON inventory_transfers(status);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_admin ON sales(admin_id);
CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);
CREATE INDEX idx_online_orders_status ON online_orders(status);
CREATE INDEX idx_online_order_items_order ON online_order_items(order_id);
CREATE INDEX idx_online_order_items_product ON online_order_items(product_id);
CREATE INDEX idx_referral_earnings_referee ON referral_earnings(referee_id);
CREATE INDEX idx_referral_earnings_order ON referral_earnings(order_id);
CREATE INDEX idx_referral_customers_customer ON referral_customers(customer_id);
CREATE INDEX idx_referral_customers_referee ON referral_customers(referee_id);
CREATE INDEX idx_settings_key ON settings(key);

-- Create RLS policies
CREATE POLICY "Enable read access for authenticated users"
ON products FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON products FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Create function to check admin role
CREATE OR REPLACE FUNCTION check_admin_role(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM user_roles
    WHERE user_id = user_id
    AND role = 'admin'
  );
END;
$$;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON FUNCTION check_admin_role TO authenticated;