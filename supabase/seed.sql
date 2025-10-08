-- Seed Data for Vaccine Tracker MVP
-- Purpose: Test data for development and quickstart validation
-- Usage: Run after migration 001_initial_schema.sql

-- ============================================================================
-- CLEAR EXISTING TEST DATA (Optional - for re-running seed)
-- ============================================================================

DELETE FROM scan_events WHERE scanned_by LIKE '%@example.com';
DELETE FROM qr_codes WHERE serial LIKE 'SEED%';

-- ============================================================================
-- SEED: qr_codes
-- Insert 3 test QR codes with different GTINs and batches
-- ============================================================================

INSERT INTO qr_codes (gtin, batch, expiry, serial, qr_data, created_by) VALUES
  (
    '12345678901234',
    'BATCH001',
    '2025-12-31',
    'SEED001',
    '(01)12345678901234(10)BATCH001(17)251231(21)SEED001',
    'admin@example.com'
  ),
  (
    '12345678901234',
    'BATCH001',
    '2025-12-31',
    'SEED002',
    '(01)12345678901234(10)BATCH001(17)251231(21)SEED002',
    'admin@example.com'
  ),
  (
    '98765432109876',
    'BATCH002',
    '2026-06-30',
    'SEED003',
    '(01)98765432109876(10)BATCH002(17)260630(21)SEED003',
    'admin@example.com'
  );

-- ============================================================================
-- SEED: scan_events
-- Insert 2 test scan events for SEED001 and SEED002
-- ============================================================================

INSERT INTO scan_events (qr_code_id, scanned_by, device_info, scanned_at)
SELECT
  id,
  'scanner@example.com',
  'Test Device - iPhone 12, iOS 16.3',
  NOW() - INTERVAL '5 minutes'
FROM qr_codes
WHERE serial = 'SEED001';

INSERT INTO scan_events (qr_code_id, scanned_by, device_info, scanned_at)
SELECT
  id,
  'scanner@example.com',
  'Test Device - Android Pixel 6, Android 13',
  NOW() - INTERVAL '2 minutes'
FROM qr_codes
WHERE serial = 'SEED002';

-- ============================================================================
-- VERIFICATION
-- Query to verify seed data was inserted correctly
-- ============================================================================

-- Check QR codes
SELECT
  serial,
  gtin,
  batch,
  expiry,
  created_by,
  created_at
FROM qr_codes
WHERE serial LIKE 'SEED%'
ORDER BY created_at DESC;

-- Check scan events
SELECT
  se.id,
  qr.serial,
  se.scanned_by,
  se.device_info,
  se.scanned_at
FROM scan_events se
JOIN qr_codes qr ON se.qr_code_id = qr.id
WHERE se.scanned_by LIKE '%@example.com'
ORDER BY se.scanned_at DESC;

-- Expected Output:
-- 3 QR codes (SEED001, SEED002, SEED003)
-- 2 scan events (for SEED001 and SEED002)
