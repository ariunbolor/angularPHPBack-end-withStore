-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  parent_id uuid REFERENCES categories(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users"
ON categories FOR SELECT
USING (true);

CREATE POLICY "Enable write access for authenticated users"
ON categories FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
  ('Vitamins & Supplements', 'Essential vitamins and dietary supplements'),
  ('Pain Relief', 'Pain relief medications and treatments'),
  ('First Aid', 'First aid supplies and equipment'),
  ('Personal Care', 'Personal care and hygiene products'),
  ('Health Foods', 'Healthy food products and supplements');

-- Add category_id to products if not exists
ALTER TABLE products ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES categories(id);

-- Create index
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);