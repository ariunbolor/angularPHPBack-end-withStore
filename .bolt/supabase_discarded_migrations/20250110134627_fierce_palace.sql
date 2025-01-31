-- Add indexes
ALTER TABLE wishlist_items
ADD INDEX idx_wishlist_id (wishlist_id),
ADD INDEX idx_product_id (product_id);

-- Add unique constraint
ALTER TABLE wishlist_items
ADD UNIQUE KEY unique_wishlist_product (wishlist_id, product_id);

-- Add foreign key constraints
ALTER TABLE wishlist_items
ADD CONSTRAINT fk_wishlist_items_wishlist
FOREIGN KEY (wishlist_id) REFERENCES wishlists(id) ON DELETE CASCADE;

ALTER TABLE wishlist_items
ADD CONSTRAINT fk_wishlist_items_product
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;