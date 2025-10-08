-- Migration: Allow Anonymous Access for MVP
-- Created: 2025-10-05
-- Description: Temporarily allow anonymous users to insert/read QR codes and scan events
-- Reason: MVP doesn't have authentication yet (coming in Phase 3.6)
-- Security: This is acceptable for MVP testing. Add proper auth before production.

-- ============================================================================
-- DROP EXISTING RESTRICTIVE POLICIES
-- ============================================================================

DROP POLICY IF EXISTS "Authenticated users can read QR codes" ON qr_codes;
DROP POLICY IF EXISTS "Authenticated users can create QR codes" ON qr_codes;
DROP POLICY IF EXISTS "Authenticated users can read scan events" ON scan_events;
DROP POLICY IF EXISTS "Authenticated users can create scan events" ON scan_events;

-- ============================================================================
-- CREATE PERMISSIVE POLICIES FOR MVP
-- ============================================================================

-- QR Codes: Allow all authenticated AND anonymous users
CREATE POLICY "Anyone can read QR codes (MVP)"
  ON qr_codes
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create QR codes (MVP)"
  ON qr_codes
  FOR INSERT
  WITH CHECK (true);

-- Scan Events: Allow all authenticated AND anonymous users
CREATE POLICY "Anyone can read scan events (MVP)"
  ON scan_events
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create scan events (MVP)"
  ON scan_events
  FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- NOTES FOR FUTURE PHASES
-- ============================================================================

-- TODO (Phase 3.6+): Replace these policies with proper authentication
-- When implementing auth, run this migration:
--
-- DROP POLICY "Anyone can read QR codes (MVP)" ON qr_codes;
-- DROP POLICY "Anyone can create QR codes (MVP)" ON qr_codes;
--
-- CREATE POLICY "Authenticated users can read QR codes"
--   ON qr_codes FOR SELECT
--   USING (auth.role() = 'authenticated');
--
-- CREATE POLICY "Authenticated users can create QR codes"
--   ON qr_codes FOR INSERT
--   WITH CHECK (auth.role() = 'authenticated');
