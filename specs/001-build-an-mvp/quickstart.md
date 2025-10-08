# Quickstart: MVP Vaccine Tracking System

**Feature**: 001-build-an-mvp
**Purpose**: Manual testing guide for end-to-end workflow validation
**Target**: Local network testing with physical mobile device

---

## Prerequisites

- [ ] Supabase project created (free tier) OR local Supabase instance running
- [ ] Next.js web app running on `http://localhost:3000`
- [ ] Flutter mobile app installed on physical device (iOS or Android)
- [ ] Both laptop and phone connected to same WiFi network
- [ ] Local IP address configured in mobile app (e.g., `192.168.1.100`)

---

## Setup (First Time Only)

### 1. Initialize Database
```bash
# Navigate to project root
cd vaccine-tracker

# Run Supabase migration (if using local instance)
supabase db reset

# OR apply migration to hosted Supabase project
supabase db push
```

**Expected Result**: Tables `qr_codes` and `scan_events` created with indexes

### 2. Start Web Application
```bash
cd web
npm install
npm run dev
```

**Expected Output**:
```
> vaccine-tracker-web@1.0.0 dev
> next dev

- ready started server on 0.0.0.0:3000, url: http://localhost:3000
- Local Network: http://192.168.1.100:3000
```

**Action**: Copy the Local Network URL (e.g., `http://192.168.1.100:3000`)

### 3. Start Mobile Application
```bash
cd mobile
flutter run
```

**Choose device**: Select physical device from list (e.g., "iPhone 12")

**Expected Output**: App launches and shows login screen

**Action**: Note the "API URL" input field - paste your Local Network URL here

---

## Test Scenario 1: Generate QR Code

### Steps
1. Open browser: `http://localhost:3000/generate`
2. Fill in QR Generator form:
   - **GTIN**: `12345678901234` (14 digits)
   - **Batch Number**: `BATCH001`
   - **Expiry Date**: `2025-12-31` (future date)
   - **Serial Number**: `TEST001` (must be unique)
3. Observe live QR preview updating as you type
4. Click **"Generate QR Code"** button
5. Click **"Download QR"** to save PNG image

### Expected Results
- [x] QR code preview appears within 100ms of typing
- [x] GS1 format displayed: `(01)12345678901234(10)BATCH001(17)251231(21)TEST001`
- [x] Success message: "QR code generated successfully"
- [x] Download starts (PNG file: `vaccine-qr-TEST001.png`)
- [x] New entry appears in "Recent QR Codes" table

### Validation
```bash
# Query database to confirm QR was saved
psql $DATABASE_URL -c "SELECT serial, qr_data FROM qr_codes WHERE serial = 'TEST001';"
```

**Expected Output**:
```
  serial  |                      qr_data
----------+---------------------------------------------------
 TEST001  | (01)12345678901234(10)BATCH001(17)251231(21)TEST001
```

---

## Test Scenario 2: Scan QR Code with Mobile App

### Steps
1. Display QR code on laptop screen:
   - Open downloaded PNG OR keep generator page open with preview
2. On mobile app:
   - Enter email: `scanner@example.com`
   - Tap **"Login"** (simple auth, no password for MVP)
3. Camera viewfinder opens automatically
4. Point camera at QR code on laptop screen
5. Wait for scan detection (vibration feedback)

### Expected Results
- [x] Camera permission granted on first launch
- [x] Live viewfinder shows camera feed
- [x] QR code detected within 1-2 seconds
- [x] Phone vibrates on successful scan
- [x] Scanned data screen displays:
  - **GTIN**: 12345678901234
  - **Batch**: BATCH001
  - **Expiry**: 2025-12-31
  - **Serial**: TEST001
- [x] Success message: "Scan recorded successfully"
- [x] Scan appears in "Last 5 Scans" list at bottom

### Troubleshooting
- **QR not detected**: Increase brightness on laptop screen, hold phone steady
- **Network error**: Verify API URL matches laptop's local IP
- **Camera black screen**: Check camera permissions in phone settings

---

## Test Scenario 3: View Real-Time Dashboard

### Steps
1. Keep mobile app open after Scenario 2 scan
2. Open dashboard on laptop: `http://localhost:3000`
3. Observe scan appearing in real-time feed
4. Generate another QR code (serial: `TEST002`)
5. Scan `TEST002` with mobile app
6. Watch dashboard auto-update without refresh

### Expected Results
- [x] Dashboard loads within 1 second
- [x] **Total Scans** counter shows correct count (e.g., `1`)
- [x] Recent scans table shows:
  - Timestamp (e.g., "2 minutes ago")
  - Scanner email (`scanner@example.com`)
  - QR data (`(01)12345678901234...`)
- [x] When new scan happens:
  - Dashboard updates within 1 second (no page refresh)
  - New row appears at top of table
  - Total scans counter increments
  - Animation/highlight on new row (optional)

### Validation (Real-Time Check)
1. Open browser DevTools → Network tab
2. Look for WebSocket connection to Supabase Realtime
3. Perform scan on mobile
4. Observe WebSocket message received (no HTTP polling)

**Expected**: WebSocket event `postgres_changes` with `INSERT` on `scan_events`

---

## Test Scenario 4: Edge Cases

### 4A: Duplicate Serial Number
1. Try to generate QR with serial `TEST001` (already used)
2. Expected: Error message "Serial number already exists"

### 4B: Invalid GTIN
1. Enter GTIN: `123` (too short)
2. Expected: Client-side validation error "GTIN must be 14 digits"

### 4C: Scan Non-Vaccine QR Code
1. Display any random QR code (e.g., website URL)
2. Scan with mobile app
3. Expected: Error message "Invalid vaccine QR code format"

### 4D: Network Interruption
1. Disable WiFi on phone during scan
2. Scan QR code
3. Expected: Error toast "Network error - scan not recorded"
4. Re-enable WiFi
5. Tap "Retry" button
6. Expected: Scan successfully recorded

### 4E: Multiple Scans of Same QR
1. Scan `TEST001` multiple times (3 scans)
2. Expected:
   - Each scan creates new `scan_event` row
   - Dashboard shows 3 separate entries
   - Mobile app "Last 5 Scans" shows all 3 with timestamps

---

## Test Scenario 5: Mobile Responsiveness

### Steps
1. Open dashboard on phone browser: `http://{LOCAL_IP}:3000`
2. Navigate to QR generator: `http://{LOCAL_IP}:3000/generate`
3. Test form input and QR preview on mobile screen
4. View recent scans table

### Expected Results
- [x] Dashboard layout responsive (single column on mobile)
- [x] QR preview scales to fit screen
- [x] Form inputs sized appropriately for touch
- [x] Table scrolls horizontally if needed
- [x] No horizontal overflow or layout breaks

---

## Performance Benchmarks

### QR Code Generation
- [ ] Live preview updates: < 100ms after typing stops
- [ ] Server-side generation: < 500ms (POST `/api/qr/generate`)
- [ ] QR image download: < 1s

### Mobile Scanning
- [ ] Camera initialization: < 2s
- [ ] QR detection: < 3s (clear, steady camera)
- [ ] Scan recording: < 500ms (POST `/api/scan`)
- [ ] UI update after scan: < 1s

### Dashboard Real-Time
- [ ] Initial load: < 2s
- [ ] WebSocket connection: < 1s
- [ ] Real-time update latency: < 1s from scan to dashboard display

### Hot Reload (Development)
- [ ] Next.js web: < 1s (file save to browser refresh)
- [ ] Flutter mobile: < 3s (file save to app reload)

---

## Success Criteria

This quickstart is complete when:
- [x] All 5 test scenarios pass
- [x] End-to-end workflow works: Generate → Scan → View
- [x] Real-time updates work without page refresh
- [x] Mobile app connects via local network
- [x] All performance benchmarks met
- [x] Edge cases handled gracefully

---

## Troubleshooting Guide

### "Cannot connect to API" on mobile
- **Check**: WiFi - laptop and phone on same network?
- **Check**: Firewall - port 3000 open on laptop?
- **Fix**: Use `0.0.0.0` in Next.js config, not `localhost`
- **Test**: Browser on phone can access `http://{LOCAL_IP}:3000`

### "QR code preview not showing"
- **Check**: Browser console for errors
- **Check**: `qrcode.js` library loaded correctly
- **Fix**: Clear cache and hard reload (Cmd+Shift+R)

### "Dashboard not updating in real-time"
- **Check**: WebSocket connection status in DevTools
- **Check**: Supabase Realtime enabled on `scan_events` table
- **Fix**: Run migration: `ALTER PUBLICATION supabase_realtime ADD TABLE scan_events;`

### "Camera permission denied" on mobile
- **Fix iOS**: Settings → Privacy → Camera → [App Name] → Enable
- **Fix Android**: Settings → Apps → [App Name] → Permissions → Camera → Allow

### "Scan detected but error saving"
- **Check**: Mobile app API URL correct?
- **Check**: Database connection from web app?
- **Check**: Serial number exists in `qr_codes` table?
- **Debug**: Check web app logs for database errors

---

## Cleanup

### Remove Test Data
```sql
-- Delete test scan events
DELETE FROM scan_events WHERE scanned_by = 'scanner@example.com';

-- Delete test QR codes
DELETE FROM qr_codes WHERE serial LIKE 'TEST%';
```

### Reset Database
```bash
supabase db reset  # Local only - WARNING: deletes all data
```

---

## Next Steps

After quickstart validation:
1. Run `/tasks` to generate implementation tasks
2. Execute tasks following TDD approach (optional for MVP)
3. Test on multiple devices (iOS + Android)
4. Deploy to staging (Vercel + Supabase hosted)
5. User acceptance testing with real vaccine data

---

**Last Updated**: 2025-10-05
**Validated On**: [Pending - run quickstart to validate]
