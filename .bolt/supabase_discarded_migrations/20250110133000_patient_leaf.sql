-- Create web_users table
CREATE TABLE web_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create wishlists table
CREATE TABLE wishlists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES web_users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create wishlist_items table
CREATE TABLE wishlist_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wishlist_id uuid REFERENCES wishlists(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(wishlist_id, product_id)
);

-- Enable RLS
ALTER TABLE web_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own data"
  ON web_users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can update their own data"
  ON web_users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Users can view their own wishlist"
  ON wishlists FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can manage their own wishlist"
  ON wishlists FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view their wishlist items"
  ON wishlist_items FOR SELECT
  USING (wishlist_id IN (
    SELECT id FROM wishlists WHERE user_id = auth.uid()
  ));

CREATE POLICY "Users can manage their wishlist items"
  ON wishlist_items FOR ALL
  USING (wishlist_id IN (
    SELECT id FROM wishlists WHERE user_id = auth.uid()
  ))
  WITH CHECK (wishlist_id IN (
    SELECT id FROM wishlists WHERE user_id = auth.uid()
  ));

-- Create indexes
CREATE INDEX idx_web_users_email ON web_users(email);
CREATE INDEX idx_wishlists_user ON wishlists(user_id);
CREATE INDEX idx_wishlist_items_wishlist ON wishlist_items(wishlist_id);
CREATE INDEX idx_wishlist_items_product ON wishlist_items(product_id);