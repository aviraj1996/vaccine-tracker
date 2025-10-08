# Data Model: MVP Vaccine Tracking System

**Feature**: 001-build-an-mvp
**Date**: 2025-10-05
**Status**: Complete

## Overview
Simple two-table schema for MVP vaccine tracking. Supports GS1-formatted QR codes and real-time scan event tracking. Single-tenant architecture with optional user attribution.

---

## Entity: QRCode

### Purpose
Represents a generated vaccine QR code with GS1-formatted data. Tracks creation metadata for audit trail.

### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier |
| gtin | TEXT | NOT NULL | Global Trade Item Number (14 digits, zero-padded) |
| batch | TEXT | NOT NULL | Batch/Lot number (alphanumeric, max 20 chars) |
| expiry | DATE | NOT NULL | Vaccine expiry date |
| serial | TEXT | NOT NULL, UNIQUE | Serial number (unique per dose, max 20 chars) |
| qr_data | TEXT | NOT NULL | Full GS1 encoded string: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Timestamp of QR generation |
| created_by | TEXT | NULLABLE | Email of user who generated QR (optional, from auth) |

### Indexes
- `idx_qr_serial` on `serial` - Fast lookup when scanning QR (most common query)
- `idx_qr_created` on `created_at DESC` - Recent QR codes list on dashboard

### Validation Rules
- **GTIN**: Must be exactly 14 digits (validate client-side)
- **Batch**: Max 20 characters, alphanumeric only
- **Expiry**: Cannot be in the past (soft validation, warning only)
- **Serial**: Max 20 characters, must be globally unique
- **QR Data**: Auto-generated from GTIN/Batch/Expiry/Serial, immutable after creation

### State Transitions
N/A - QR codes are immutable after creation (no updates/deletes in MVP)

### Relationships
- **One-to-Many** with ScanEvent: A QR code can be scanned multiple times

---

## Entity: ScanEvent

### Purpose
Represents a single scan action performed by a mobile user. Captures when, where, and by whom a QR code was scanned.

### Fields

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Unique identifier |
| qr_code_id | UUID | FOREIGN KEY → qr_codes(id) ON DELETE CASCADE, NOT NULL | Reference to scanned QR code |
| scanned_by | TEXT | NOT NULL | Email of user who scanned (from auth session) |
| scanned_at | TIMESTAMPTZ | DEFAULT NOW() | Timestamp of scan action |
| device_info | TEXT | NULLABLE | Device model/OS for debugging (e.g., "iPhone 12, iOS 16.3") |

### Indexes
- `idx_scan_time` on `scanned_at DESC` - Real-time feed ordering (newest first)
- `idx_scan_user` on `scanned_by` - Filter scans by user (future analytics)
- Automatic index on `qr_code_id` (foreign key)

### Validation Rules
- **scanned_by**: Must be valid email format (enforced by auth)
- **qr_code_id**: Must reference existing QR code (foreign key constraint)

### State Transitions
N/A - Scan events are immutable (append-only log)

### Relationships
- **Many-to-One** with QRCode: Multiple scans can reference the same QR code

---

## Relationship Diagram

```
┌─────────────────────────────┐
│ QRCode                      │
├─────────────────────────────┤
│ id (PK)                     │
│ gtin                        │
│ batch                       │
│ expiry                      │
│ serial (UNIQUE)             │
│ qr_data                     │
│ created_at                  │
│ created_by                  │
└──────────────┬──────────────┘
               │
               │ 1:N
               │
               ▼
┌─────────────────────────────┐
│ ScanEvent                   │
├─────────────────────────────┤
│ id (PK)                     │
│ qr_code_id (FK)             │
│ scanned_by                  │
│ scanned_at                  │
│ device_info                 │
└─────────────────────────────┘
```

---

## Query Patterns

### Dashboard Queries

**Recent Scans (Real-time Feed)**
```sql
SELECT
  se.id,
  se.scanned_at,
  se.scanned_by,
  qr.gtin,
  qr.batch,
  qr.serial,
  qr.qr_data
FROM scan_events se
JOIN qr_codes qr ON se.qr_code_id = qr.id
ORDER BY se.scanned_at DESC
LIMIT 50;
```
- Uses: `idx_scan_time` index
- Expected performance: < 10ms
- Real-time subscription on `scan_events` table (INSERT events)

**Total Scan Count**
```sql
SELECT COUNT(*) FROM scan_events;
```
- Expected performance: < 5ms (index-only scan)

**Recent QR Generations**
```sql
SELECT
  id,
  gtin,
  batch,
  serial,
  created_at,
  created_by
FROM qr_codes
ORDER BY created_at DESC
LIMIT 20;
```
- Uses: `idx_qr_created` index
- Expected performance: < 10ms

### Mobile App Queries

**Lookup QR Code by Serial (after scan)**
```sql
SELECT * FROM qr_codes WHERE serial = $1;
```
- Uses: `idx_qr_serial` index
- Expected performance: < 5ms (unique index lookup)

**Insert Scan Event**
```sql
INSERT INTO scan_events (qr_code_id, scanned_by, device_info)
VALUES ($1, $2, $3)
RETURNING *;
```
- Triggers real-time notification to dashboard subscribers
- Expected performance: < 20ms

**Last 5 Scans for User**
```sql
SELECT
  se.id,
  se.scanned_at,
  qr.gtin,
  qr.batch,
  qr.serial
FROM scan_events se
JOIN qr_codes qr ON se.qr_code_id = qr.id
WHERE se.scanned_by = $1
ORDER BY se.scanned_at DESC
LIMIT 5;
```
- Uses: `idx_scan_user` and `idx_scan_time` indexes
- Expected performance: < 15ms

### QR Generator Queries

**Create QR Code**
```sql
INSERT INTO qr_codes (gtin, batch, expiry, serial, qr_data, created_by)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING *;
```
- Serial uniqueness enforced by UNIQUE constraint
- Expected performance: < 15ms

---

## Data Migration Strategy

### Initial Schema (Migration 001)
```sql
-- Create QR codes table
CREATE TABLE qr_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  gtin TEXT NOT NULL,
  batch TEXT NOT NULL,
  expiry DATE NOT NULL,
  serial TEXT NOT NULL UNIQUE,
  qr_data TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT
);

-- Create indexes
CREATE INDEX idx_qr_serial ON qr_codes(serial);
CREATE INDEX idx_qr_created ON qr_codes(created_at DESC);

-- Create scan events table
CREATE TABLE scan_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  qr_code_id UUID NOT NULL REFERENCES qr_codes(id) ON DELETE CASCADE,
  scanned_by TEXT NOT NULL,
  scanned_at TIMESTAMPTZ DEFAULT NOW(),
  device_info TEXT
);

-- Create indexes
CREATE INDEX idx_scan_time ON scan_events(scanned_at DESC);
CREATE INDEX idx_scan_user ON scan_events(scanned_by);

-- Enable real-time for scan events (Supabase specific)
ALTER PUBLICATION supabase_realtime ADD TABLE scan_events;
```

### Seed Data (Development Only)
```sql
-- Insert test QR codes
INSERT INTO qr_codes (gtin, batch, expiry, serial, qr_data, created_by) VALUES
  ('12345678901234', 'BATCH001', '2025-12-31', 'SN001', '(01)12345678901234(10)BATCH001(17)251231(21)SN001', 'test@example.com'),
  ('12345678901234', 'BATCH001', '2025-12-31', 'SN002', '(01)12345678901234(10)BATCH001(17)251231(21)SN002', 'test@example.com'),
  ('98765432109876', 'BATCH002', '2026-06-30', 'SN003', '(01)98765432109876(10)BATCH002(17)260630(21)SN003', 'test@example.com');

-- Insert test scan events
INSERT INTO scan_events (qr_code_id, scanned_by, device_info)
SELECT id, 'scanner@example.com', 'Test Device'
FROM qr_codes
WHERE serial = 'SN001';
```

---

## Supabase Row Level Security (RLS)

### Optional: Basic Auth Policies
If using Supabase Auth (email/password):

```sql
-- Enable RLS
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_events ENABLE ROW LEVEL SECURITY;

-- QR Codes: Anyone authenticated can read, only authenticated users can create
CREATE POLICY "Authenticated users can read QR codes"
  ON qr_codes FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create QR codes"
  ON qr_codes FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Scan Events: Anyone authenticated can read and create
CREATE POLICY "Authenticated users can read scan events"
  ON scan_events FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create scan events"
  ON scan_events FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
```

**Note**: For MVP, RLS can be disabled initially for faster development. Enable before production.

---

## Storage Estimates (Free Tier Validation)

### QR Codes Table
- Avg row size: ~200 bytes (UUID + text fields)
- 10,000 QR codes: ~2MB
- 100,000 QR codes: ~20MB

### Scan Events Table
- Avg row size: ~150 bytes (2 UUIDs + timestamps + text)
- 100,000 scans: ~15MB
- 1,000,000 scans: ~150MB

**Total for MVP**: ~50MB (well within 500MB free tier limit)

---

## Real-Time Subscription Configuration

### Dashboard Subscription
```typescript
// Subscribe to new scan events
const channel = supabase
  .channel('dashboard-scans')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'scan_events'
  }, (payload) => {
    // payload.new contains the new scan_event row
    // Fetch related QR code data and update UI
  })
  .subscribe();
```

### Mobile App Subscription (Optional)
```dart
// Subscribe to own scans for real-time confirmation
final subscription = supabase
  .from('scan_events')
  .stream(primaryKey: ['id'])
  .eq('scanned_by', userEmail)
  .order('scanned_at', ascending: false)
  .limit(5)
  .listen((data) {
    // Update last 5 scans list
  });
```

---

## Summary

**Entities**: 2 (QRCode, ScanEvent)
**Relationships**: 1 (One-to-Many)
**Indexes**: 4 (optimized for query patterns)
**Migrations**: 1 initial schema
**RLS Policies**: Optional (4 policies for auth)

**Validation**: All constitutional principles satisfied
- ✅ Simple schema (2 tables, no over-engineering)
- ✅ Real-time capable (LISTEN/NOTIFY via Supabase)
- ✅ Free tier compliant (< 50MB for MVP)
- ✅ Performance optimized (< 20ms for all queries)

**Ready for contract generation.**
