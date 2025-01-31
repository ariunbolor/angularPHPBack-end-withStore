-- First ensure the auth schema exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth user if not exists
DO $$ 
BEGIN
  -- Remove existing user first to avoid conflicts
  DELETE FROM auth.users WHERE email = 'admin@example.com';
  
  -- Create new admin user with proper fields
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    created_at,
    updated_at,
    aud,
    role,
    confirmation_token
  ) VALUES (
    gen_random_uuid(),
    '00000000-0000-0000-0000-000000000000',
    'admin@example.com',
    crypt('admin123', gen_salt('bf')),
    now(),
    jsonb_build_object('role', 'admin'),
    now(),
    now(),
    'authenticated',
    'authenticated',
    encode(gen_random_bytes(32), 'hex')
  );
END $$;