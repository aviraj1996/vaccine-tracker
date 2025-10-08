-- Migration: Initial Schema for Vaccine Tracker MVP
-- Created: 2025-10-05
-- Description: Creates qr_codes and scan_events tables with indexes and RLS policies

-- ============================================================================
-- TABLE: qr_codes
-- Purpose: Stores generated vaccine QR codes with GS1-formatted data
-- ============================================================================

CREATE TABLE IF NOT EXISTS qr_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  gtin TEXT NOT NULL,
  batch TEXT NOT NULL,
  expiry DATE NOT NULL,
  serial TEXT NOT NULL UNIQUE,
  qr_data TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT
);

-- Add comment for documentation
COMMENT ON TABLE qr_codes IS 'Vaccine QR codes with GS1-formatted data';
COMMENT ON COLUMN qr_codes.gtin IS 'Global Trade Item Number (14 digits)';
COMMENT ON COLUMN qr_codes.batch IS 'Batch/Lot number (max 20 chars alphanumeric)';
COMMENT ON COLUMN qr_codes.expiry IS 'Vaccine expiry date';
COMMENT ON COLUMN qr_codes.serial IS 'Unique serial number per dose';
COMMENT ON COLUMN qr_codes.qr_data IS 'Full GS1 encoded string: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL';
COMMENT ON COLUMN qr_codes.created_by IS 'Email of user who generated QR (optional)';

-- ============================================================================
-- INDEXES: qr_codes
-- ============================================================================

-- Fast lookup when scanning QR (most common query)
CREATE INDEX idx_qr_serial ON qr_codes(serial);

-- Recent QR codes list on dashboard
CREATE INDEX idx_qr_created ON qr_codes(created_at DESC);

-- ============================================================================
-- TABLE: scan_events
-- Purpose: Records each QR code scan action with timestamp and user info
-- ============================================================================

CREATE TABLE IF NOT EXISTS scan_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  qr_code_id UUID NOT NULL REFERENCES qr_codes(id) ON DELETE CASCADE,
  scanned_by TEXT NOT NULL,
  scanned_at TIMESTAMPTZ DEFAULT NOW(),
  device_info TEXT
);

-- Add comments
COMMENT ON TABLE scan_events IS 'QR code scan events for tracking';
COMMENT ON COLUMN scan_events.qr_code_id IS 'Foreign key to qr_codes table';
COMMENT ON COLUMN scan_events.scanned_by IS 'Email of user who scanned';
COMMENT ON COLUMN scan_events.device_info IS 'Device model/OS for debugging (e.g., iPhone 12, iOS 16.3)';

-- ============================================================================
-- INDEXES: scan_events
-- ============================================================================

-- Real-time feed ordering (newest first)
CREATE INDEX idx_scan_time ON scan_events(scanned_at DESC);

-- Filter scans by user (for mobile app "last 5 scans")
CREATE INDEX idx_scan_user ON scan_events(scanned_by);

-- Automatic index on foreign key (qr_code_id) for JOIN performance

-- ============================================================================
-- REAL-TIME REPLICATION
-- Enable real-time updates for dashboard
-- ============================================================================

-- Enable real-time for scan_events table
ALTER PUBLICATION supabase_realtime ADD TABLE scan_events;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- Single-tenant MVP: All authenticated users have equal access
-- ============================================================================

-- Enable RLS on both tables
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_events ENABLE ROW LEVEL SECURITY;

-- QR Codes Policies
-- Allow authenticated users to read all QR codes
CREATE POLICY "Authenticated users can read QR codes"
  ON qr_codes
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Allow authenticated users to create QR codes
CREATE POLICY "Authenticated users can create QR codes"
  ON qr_codes
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Scan Events Policies
-- Allow authenticated users to read all scan events
CREATE POLICY "Authenticated users can read scan events"
  ON scan_events
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Allow authenticated users to create scan events
CREATE POLICY "Authenticated users can create scan events"
  ON scan_events
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- ============================================================================
-- VERIFICATION QUERIES
-- Run these after migration to verify setup
-- ============================================================================

-- List all tables
-- \dt

-- Check indexes
-- SELECT tablename, indexname FROM pg_indexes WHERE schemaname = 'public';

-- Verify RLS enabled
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';

-- Test insert (should work as authenticated user)
-- INSERT INTO qr_codes (gtin, batch, expiry, serial, qr_data)
-- VALUES ('12345678901234', 'TEST', '2025-12-31', 'SERIAL001', '(01)12345678901234(10)TEST(17)251231(21)SERIAL001');
