-- Quick Fix: Allow Anonymous Access for MVP Testing
-- Run this in Supabase SQL Editor to fix "row level security policy" error
-- This allows the web app to insert QR codes without authentication

-- Drop old restrictive policies
DROP POLICY IF EXISTS "Authenticated users can read QR codes" ON qr_codes;
DROP POLICY IF EXISTS "Authenticated users can create QR codes" ON qr_codes;
DROP POLICY IF EXISTS "Authenticated users can read scan events" ON scan_events;
DROP POLICY IF EXISTS "Authenticated users can create scan events" ON scan_events;

-- Create new permissive policies for MVP
CREATE POLICY "Anyone can read QR codes (MVP)"
  ON qr_codes FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create QR codes (MVP)"
  ON qr_codes FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can read scan events (MVP)"
  ON scan_events FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create scan events (MVP)"
  ON scan_events FOR INSERT
  WITH CHECK (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE tablename IN ('qr_codes', 'scan_events');
