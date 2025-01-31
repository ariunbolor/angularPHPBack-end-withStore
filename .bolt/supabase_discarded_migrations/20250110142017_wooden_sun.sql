-- Create password_resets table
CREATE TABLE IF NOT EXISTS password_resets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES web_users(id) ON DELETE CASCADE,
  token text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE password_resets ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for own resets"
ON password_resets FOR SELECT
USING (user_id IN (
  SELECT id FROM web_users 
  WHERE auth_id = auth.uid()
));

-- Create indexes
CREATE INDEX idx_password_resets_token ON password_resets(token);
CREATE INDEX idx_password_resets_user ON password_resets(user_id);

-- Create function to request password reset
CREATE OR REPLACE FUNCTION request_password_reset(user_email text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM web_users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RETURN false;
  END IF;

  -- Insert reset record
  INSERT INTO password_resets (
    user_id,
    token,
    expires_at
  ) VALUES (
    v_user_id,
    encode(gen_random_bytes(32), 'hex'),
    now() + interval '1 hour'
  );

  RETURN true;
END;
$$;