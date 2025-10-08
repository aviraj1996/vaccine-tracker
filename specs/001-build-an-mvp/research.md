# Research: MVP Vaccine Tracking System

**Feature**: 001-build-an-mvp
**Date**: 2025-10-05
**Status**: Complete

## Overview
Research findings for building an MVP vaccine tracking system with web-based QR generation, mobile scanning, and real-time dashboard using free-tier services only.

---

## Key Technology Decisions

### 1. Mobile Framework: Flutter
**Decision**: Use Flutter for cross-platform mobile app (iOS + Android)

**Rationale**:
- Single codebase for both iOS and Android reduces development time
- Excellent camera/QR scanning support via `mobile_scanner` package (uses platform-native APIs)
- Hot reload enables rapid iteration (< 3s reload time)
- Strong Supabase integration via `supabase_flutter` package
- Native performance for camera operations

**Alternatives Considered**:
- React Native: Good option but Flutter has better camera performance and simpler setup
- Native (Swift/Kotlin): Higher quality but 2x development time, violates MVP speed principle

**Implementation Notes**:
- Use `mobile_scanner` package for QR scanning (platform-optimized)
- Use `supabase_flutter` for real-time subscriptions
- Target iOS 12+ and Android 8+ for broad device support

---

### 2. Web Framework: Next.js 14+
**Decision**: Use Next.js App Router for both QR generator and dashboard

**Rationale**:
- React Server Components enable efficient real-time updates
- Built-in API routes eliminate separate backend
- Excellent developer experience with hot reload (< 1s)
- Free deployment on Vercel if needed later
- TypeScript support out of the box

**Alternatives Considered**:
- Separate React + Express: More complexity, violates Zero-Config DX principle
- Vanilla React (Vite): No API routes, would need separate backend

**Implementation Notes**:
- Use App Router (app/ directory structure)
- Server Components for dashboard to minimize client JS
- Client Components for QR generator (needs live preview)
- API routes for QR generation endpoint

---

### 3. Backend: Supabase (Free Tier)
**Decision**: Use Supabase for database, real-time, and optional auth

**Rationale**:
- Free tier: 500MB database, 50k MAU, 2GB bandwidth (sufficient for MVP)
- Built-in real-time subscriptions (PostgreSQL LISTEN/NOTIFY)
- No server maintenance required
- JavaScript/Dart SDKs for web and mobile
- Optional auth (email/password) included

**Free Tier Limits**:
- 500MB database → ~50k QR codes + 500k scan events (more than enough)
- 2GB bandwidth/month → ~100k realtime messages (sufficient for 100+ users)
- 50k MAU → Plenty for MVP testing

**Alternatives Considered**:
- Firebase: Real-time works but NoSQL makes relationships harder, similar free tier
- Self-hosted PostgreSQL: Violates Zero-Config DX (deployment complexity)

**Implementation Notes**:
- Use PostgreSQL with GIN indexes for fast QR lookups
- Real-time subscriptions on `scan_events` table for dashboard
- Row Level Security (RLS) policies for basic auth (optional)

---

### 4. QR Code Generation: qrcode.js (Web) + qr_flutter (Mobile)
**Decision**: Use platform-specific QR libraries

**Rationale**:
- `qrcode.js`: Lightweight (10KB), generates canvas/SVG, no dependencies
- `qr_flutter`: Native Dart implementation, customizable, well-maintained
- Both support GS1 data encoding
- Instant generation (< 100ms) for live preview

**Alternatives Considered**:
- Server-side QR generation: Adds latency, violates Instant Feedback Loop
- Single library via API: Requires network call, slower for live preview

**Implementation Notes**:
- Web: Generate QR as Canvas element, convert to PNG for download
- Mobile: Display QR for verification (optional feature)
- GS1 format: `(01){GTIN}(10){BATCH}(17){EXPIRY}(21){SERIAL}`

---

### 5. QR Code Scanning: mobile_scanner (Flutter)
**Decision**: Use `mobile_scanner` package for camera-based scanning

**Rationale**:
- Uses native platform APIs (MLKit on Android, AVFoundation on iOS)
- Best performance for real-time camera processing
- Active maintenance, 2k+ pub.dev likes
- Supports multiple barcode formats (QR, Data Matrix, etc.)

**Alternatives Considered**:
- `qr_code_scanner`: Older, less maintained
- Web-based scanning (WebRTC): Poor camera performance on mobile browsers

**Implementation Notes**:
- Request camera permissions on app start
- Live viewfinder with overlay for UX guidance
- Parse GS1 format after successful scan
- Vibration feedback on successful scan

---

### 6. Local Network Testing Strategy
**Decision**: Use local IP address with optional ngrok fallback

**Rationale**:
- Local IP (192.168.x.x): Zero cost, lowest latency, works for same WiFi
- Auto-detect IP using Node.js `os.networkInterfaces()`
- Display IP prominently in mobile app for easy configuration
- ngrok as backup for testing across different networks (free tier: 1 active tunnel)

**Alternatives Considered**:
- Localhost only: Doesn't work for physical devices
- Always ngrok: Adds latency, free tier limits (40 connections/minute)
- Cloud deployment: Violates Free-Tier Architecture for development

**Implementation Notes**:
- Web app: Auto-detect and display local IP on startup
- Mobile app: Allow manual IP input or QR code with connection URL
- Environment variable: `NEXT_PUBLIC_API_URL` for easy switching

---

### 7. GS1 Data Format
**Decision**: Encode as `(01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL`

**Rationale**:
- GS1 Application Identifiers (AIs) are industry standard for pharmaceuticals
- AI 01: GTIN (Global Trade Item Number) - product identifier
- AI 10: Batch/Lot number
- AI 17: Expiry date (YYMMDD format)
- AI 21: Serial number (unique per dose)
- Parseable by any GS1-compliant scanner

**Implementation Notes**:
- GTIN: 14 digits (pad shorter GTINs with leading zeros)
- Expiry: YYMMDD format (e.g., 251231 = Dec 31, 2025)
- Batch: Alphanumeric, max 20 chars
- Serial: Alphanumeric, max 20 chars
- Example: `(01)12345678901234(10)ABC123(17)251231(21)SN789456`

---

### 8. Database Schema Design
**Decision**: Two simple tables - `qr_codes` and `scan_events`

**Rationale**:
- Minimal schema for MVP (no over-engineering)
- Foreign key relationship: `scan_events.qr_code_id → qr_codes.id`
- Single-tenant (no org_id needed)
- Timestamps for real-time ordering

**Schema**:
```sql
CREATE TABLE qr_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  gtin TEXT NOT NULL,
  batch TEXT NOT NULL,
  expiry DATE NOT NULL,
  serial TEXT NOT NULL UNIQUE,
  qr_data TEXT NOT NULL,  -- Full GS1 encoded string
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT  -- Email of generator (optional)
);

CREATE INDEX idx_qr_serial ON qr_codes(serial);
CREATE INDEX idx_qr_created ON qr_codes(created_at DESC);

CREATE TABLE scan_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  qr_code_id UUID REFERENCES qr_codes(id) ON DELETE CASCADE,
  scanned_by TEXT NOT NULL,  -- Email of scanner
  scanned_at TIMESTAMPTZ DEFAULT NOW(),
  device_info TEXT  -- Optional: device model/OS for debugging
);

CREATE INDEX idx_scan_time ON scan_events(scanned_at DESC);
CREATE INDEX idx_scan_user ON scan_events(scanned_by);
```

**Alternatives Considered**:
- Separate user table: Overkill for MVP (auth handles users)
- JSON columns: Reduces indexability, violates simplicity

---

### 9. Real-Time Update Strategy
**Decision**: Supabase real-time subscriptions on `scan_events` table

**Rationale**:
- PostgreSQL LISTEN/NOTIFY under the hood (< 100ms latency)
- Automatic reconnection on network issues
- Filters available (e.g., only subscribe to recent scans)
- Works across web and mobile with same API

**Implementation**:
```typescript
// Web dashboard
const subscription = supabase
  .channel('scan-events')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'scan_events'
  }, payload => {
    // Update UI with new scan
  })
  .subscribe();
```

**Alternatives Considered**:
- Polling: Wastes bandwidth, violates Instant Feedback Loop (> 1s latency)
- WebSockets (custom): Requires server setup, violates Zero-Config DX

---

### 10. Development Workflow
**Decision**: Concurrent dev servers with live reload

**Setup**:
1. Supabase: Local instance via Docker OR hosted free tier
2. Web (Next.js): `npm run dev` on port 3000
3. Mobile (Flutter): `flutter run` on physical device/emulator
4. All connect to same Supabase project

**Hot Reload Targets**:
- Next.js: < 1s (React Fast Refresh)
- Flutter: < 3s (Dart VM hot reload)
- Database changes: Manual migration re-run (acceptable for MVP)

---

## Open Questions / Assumptions

### Assumptions Made:
- Users on same WiFi network during testing
- Supabase free tier won't hit limits during MVP phase
- Basic email/password auth is sufficient (no SSO/OAuth needed)
- GS1 format is correct for vaccine tracking (confirm with stakeholder)
- No offline scanning needed (network always available)

### Future Considerations (Post-MVP):
- Offline support: Local SQLite cache + sync when online
- Advanced analytics: Scan trends, geographic distribution
- Multi-tenancy: Organization accounts with isolation
- Role-based access: Admin vs Scanner roles
- QR code expiration: Invalidate after vaccine expires
- Batch operations: Generate multiple QRs at once

---

## Summary
All technical decisions align with constitutional principles:
- ✅ Mobile-First Testing: Flutter + local network setup
- ✅ Instant Feedback Loop: Hot reload + real-time updates
- ✅ Core Flow Simplicity: Only QR gen, scan, dashboard
- ✅ Free-Tier Architecture: Supabase free tier only
- ✅ Zero-Config DX: Auto-detect IP, single command setup

**No blockers identified. Ready to proceed to Phase 1 (Design & Contracts).**
