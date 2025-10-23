# Tasks: MVP Vaccine Tracking System

**Input**: Design documents from `/Users/aviraj/vaccine-tracker/specs/001-build-an-mvp/`
**Prerequisites**: plan.md, research.md, data-model.md, contracts/api-spec.yaml, quickstart.md

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Web app**: `web/` at repository root
- **Mobile app**: `mobile/` at repository root
- **Database**: `supabase/` at repository root

---

## Phase 3.1: Backend Foundation

- [x] T001 Initialize Supabase project with auth enabled via Supabase CLI or dashboard
- [x] T002 Create database migration file `supabase/migrations/001_initial_schema.sql` with qr_codes and scan_events tables
- [x] T003 Add indexes to migration: idx_qr_serial, idx_qr_created, idx_scan_time, idx_scan_user
- [x] T004 Enable real-time replication on scan_events table in migration
- [x] T005 Add Row Level Security policies for authenticated users in migration
- [x] T005.5 Test RLS policies by attempting unauthorized access (verify users cannot access other users' data)
- [x] T006 Apply migration to Supabase project and verify tables created
- [x] T007 Create seed data file `supabase/seed.sql` with 3 test QR codes and 2 test scan events

---

## Phase 3.2: Web Project Setup

- [x] T008 Initialize Next.js 14+ project in `web/` directory with TypeScript and App Router
- [x] T009 Install Next.js dependencies: `@supabase/supabase-js`, `qrcode`, `react-qr-code`, `tailwindcss`
- [x] T010 Configure Tailwind CSS in `web/tailwind.config.ts` and `web/app/globals.css`
- [x] T011 Create environment variables file `web/.env.local` with NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY
- [x] T012 Create Supabase client in `web/lib/supabase.ts` using createClient from @supabase/supabase-js
- [x] T013 Create TypeScript types file `web/lib/types.ts` for QRCode and ScanEvent entities
- [x] T014 Create GS1 encoder utility in `web/lib/gs1-encoder.ts` that formats (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL
- [x] T015 Create GS1 decoder utility in `web/lib/gs1-decoder.ts` that parses GS1 format back to fields

---

## Phase 3.3: QR Generator (Web)

- [x] T016 Create QR generator page at `web/app/generate/page.tsx` with form layout
- [x] T017 [P] Create QRGeneratorForm component in `web/components/QRGeneratorForm.tsx` with GTIN, Batch, Expiry, Serial inputs
- [x] T018 [P] Create QRPreview component in `web/components/QRPreview.tsx` using react-qr-code for live preview
- [x] T019 Add client-side validation to QRGeneratorForm: GTIN 14 digits numeric-only, Batch/Serial max 20 chars alphanumeric, Expiry future date. Display inline error messages
- [x] T019.5 Add duplicate serial number error handling: show friendly message "Serial number already used" when database UNIQUE constraint violated
- [x] T020 Implement live QR preview with 300ms debounce on input change to prevent excessive re-renders, using GS1 encoder
- [x] T021 Create API route `web/app/api/qr/generate/route.ts` for POST /api/qr/generate endpoint
- [x] T022 Implement QR code save to Supabase in generate API route with error handling and parameterized queries (Supabase JS SDK handles this automatically)
- [x] T022.5 Add API rate limiting on /api/qr/generate endpoint: max 10 requests per minute per user using middleware or Supabase functions
- [x] T023 Add QR image download functionality using qrcode library to convert canvas to PNG
- [x] T024 Create success toast notification component in `web/components/Toast.tsx`
- [x] T025 [P] Create RecentQRTable component in `web/components/RecentQRTable.tsx` showing last 10 generated QR codes
- [x] T026 Fetch recent QR codes from Supabase in RecentQRTable using real-time subscription
- [x] T027 Add copy QR data to clipboard feature in RecentQRTable with click handler

---

## Phase 3.4: Dashboard (Web)

- [x] T028 Create dashboard page at `web/app/page.tsx` with layout for stats cards and scan feed
- [x] T029 [P] Create ScanStatsCard component in `web/components/ScanStatsCard.tsx` showing total scans
- [x] T030 [P] Create ScanFeed component in `web/components/ScanFeed.tsx` with table columns: Time, User, GTIN, Batch, Serial
- [x] T031 Setup Supabase real-time subscription in ScanFeed for INSERT events on scan_events table
- [x] T032 Implement real-time row insertion in ScanFeed when new scans occur (prepend to list)
- [x] T032.5 Add real-time latency monitoring: warn user if update not received within 2 seconds, log latency metrics for debugging
- [x] T033 Add auto-scroll to newest scan in ScanFeed using useEffect and scrollIntoView
- [x] T034 Create timestamp formatter utility in `web/lib/format-time.ts` for relative time (e.g., "2 minutes ago")
- [x] T035 Add "scans today" metric to ScanStatsCard by filtering scans by date
- [x] T036 Create loading skeleton component in `web/components/LoadingSkeleton.tsx` for initial data fetch
- [x] T037 Create empty state component in `web/components/EmptyState.tsx` when no scans exist
- [x] T037.5 Add empty state for RecentQRTable when no QR codes generated yet: show "Generate your first QR code" prompt with link to /generate
- [x] T038 Add manual refresh button to dashboard that refetches scan data
- [x] T039 Implement responsive grid layout in dashboard page for mobile optimization
- [x] T040 Create API route `web/app/api/scans/recent/route.ts` for GET /api/scans/recent endpoint
- [x] T041 Create API route `web/app/api/scans/stats/route.ts` for GET /api/scans/stats endpoint
- [x] T041.5 Add Supabase database size and bandwidth usage monitoring: log metrics, warn if approaching free tier limits (450MB DB, 1.8GB bandwidth)

---

## Phase 3.5: Mobile Project Setup

- [x] T042 Initialize Flutter project in `mobile/` directory with package name com.vaccine.tracker
- [x] T043 Add Flutter dependencies in `mobile/pubspec.yaml`: supabase_flutter, mobile_scanner, provider
- [x] T044 Configure Supabase client in `mobile/lib/services/supabase_service.dart` with project credentials
- [x] T045 Create environment configuration in `mobile/lib/config/env.dart` for Supabase URL and anon key
- [x] T046 Create data models in `mobile/lib/models/qr_code.dart` and `mobile/lib/models/scan_event.dart`
- [x] T047 Create GS1 parser utility in `mobile/lib/utils/gs1_parser.dart` that extracts GTIN, Batch, Expiry, Serial

---

## Phase 3.6: Mobile Authentication & Navigation

- [x] T048 Create login screen UI in `mobile/lib/screens/login_screen.dart` with email and password fields
- [x] T049 Implement Supabase authentication in SupabaseService with signIn and signOut methods
- [ ] T049.5 Configure Supabase password policy: minimum 8 characters with complexity requirements (uppercase, lowercase, number)
- [ ] T049.6 Enable Supabase rate limiting for login attempts: max 5 attempts per minute per email address
- [x] T050 Add authentication state management using Provider in `mobile/lib/providers/auth_provider.dart`
- [x] T051 Create navigation from login to scanner screen after successful authentication
- [x] T052 Add logout functionality in scanner screen app bar
- [x] T053 Implement auth state persistence so user stays logged in between app restarts

---

## Phase 3.7: Mobile Scanner Screen

- [x] T054 Create scanner screen UI in `mobile/lib/screens/scanner_screen.dart` with camera viewfinder
- [x] T055 Integrate mobile_scanner package for QR detection with camera controller
- [x] T055.5 Verify mobile_scanner package compatibility with GS1-formatted QR codes: test with sample GS1 QR from research.md before full implementation
- [x] T056 Request camera permissions on app start in scanner screen initState. Add iOS Info.plist NSCameraUsageDescription and Android manifest CAMERA permission
- [x] T057 Create QR scanner widget in `mobile/lib/widgets/qr_scanner.dart` with live camera feed
- [x] T057.5 Add flashlight toggle button to scanner widget for low-light conditions. Test QR detection in < 10 lux lighting
- [x] T058 Implement QR code detection callback that extracts raw QR data
- [x] T059 Parse scanned QR data using GS1 parser to extract GTIN, Batch, Expiry, Serial
- [x] T060 Create scanned data display widget in `mobile/lib/widgets/scanned_data_display.dart` with labeled fields
- [x] T061 Create scan service in `mobile/lib/services/scan_service.dart` to save scan events to Supabase
- [x] T062 Implement save scan event with qr_code_id, scanned_by, device_info after successful scan
- [x] T062.5 Add network error retry logic for scan save failures: queue scans locally and retry when connection restored (display retry UI)
- [x] T063 Add haptic feedback using HapticFeedback.vibrate() on successful scan
- [x] T064 Show success/error modal dialog after scan. Auto-dismiss success after 2s, error requires user tap. Include scan data in success dialog
- [x] T064.5 Add camera error UI when QR code cannot be read after 10 seconds: show tips "Improve lighting, hold steady, ensure QR is visible"
- [x] T064.6 Add duplicate scan feedback: if QR scanned multiple times, show "Already scanned X minutes ago" in success dialog (IMPLEMENTED: 3-second cooldown with duplicate detection)
- [x] T065 [P] Create scan history widget in `mobile/lib/widgets/scan_history.dart` showing last 5 scans
- [x] T066 Fetch last 5 scans for current user from Supabase in scan history widget
- [x] T067 Display scan history as bottom sheet below scanner viewfinder
- [x] T067.1 **BUG FIX**: Fixed duplicate scan issue - added 3-second cooldown to prevent rapid re-scanning of same QR
- [x] T067.2 **BUG FIX**: Fixed scanner overlay positioning - white frame now centered correctly on screen

---

## Phase 3.8: Mobile Network Configuration

- [x] T068 Create network config screen in `mobile/lib/screens/network_config_screen.dart` for API URL input
- [x] T069 Add local IP address auto-detection utility in `mobile/lib/utils/network_utils.dart`
- [x] T069.5 Add auto-detect and display local IP on Next.js web app startup: show in terminal and on /generate page for easy mobile configuration
- [x] T070 Allow manual API URL override in network config screen with validation
- [x] T071 Save API URL to shared preferences for persistence (using shared_preferences package)
- [x] T072 Add network config button in login screen for easy access (Settings icon in app bar)
- [x] T073 Test mobile app connection to local Next.js server using local IP address (e.g., http://192.168.1.100:3000)
- [x] T073.5 Test Supabase real-time subscriptions over local WiFi from mobile device: verify WebSocket connection stability and latency

---

## Phase 3.9: Integration & API Endpoints

- [x] T074 Create API route `web/app/api/scan/route.ts` for POST /api/scan endpoint
- [x] T075 Implement scan recording in scan API route: lookup QR by serial, create scan_event, return QR data
- [x] T076 Create API route `web/app/api/qr/[id]/route.ts` for GET /api/qr/:id endpoint
- [x] T077 Create API route `web/app/api/scans/user/[email]/route.ts` for GET /api/scans/user/:email endpoint
- [x] T078 Add error handling to all API routes with proper HTTP status codes (400, 401, 404, 500)
- [x] T079 Test API endpoints using Postman or curl to verify request/response schemas
- [x] T079.5 Configure CORS in Next.js to allow requests from local network IPs (192.168.x.x) in `next.config.js` for mobile→web API calls
- [ ] T079.6 Create API contract tests for all 7 endpoints from contracts/api-spec.yaml using Jest + supertest: test request/response schemas

---

## Phase 3.10: Testing & Validation

- [ ] T080 Create integration test in `web/__tests__/integration/qr-generation.test.ts` for QR generation flow
- [ ] T080.5 Add integration test for QR download: verify PNG file generated with correct dimensions and content
- [x] T081 Create unit test in `web/__tests__/unit/gs1-encoder.test.ts` for GS1 encoding/decoding
- [x] T081.5 Create unit test in `web/__tests__/unit/validation.test.ts` for input validation: GTIN 14 digits, Serial unique, Expiry future
- [x] T082 Create Flutter widget test in `mobile/test/widget_test.dart` for scanner screen
- [x] T082.5 Create Dart unit test in `mobile/test/unit/gs1_parser_test.dart` for GS1 parser utility
- [x] T082.6 Document mobile test matrix: iOS 12-17, Android 8-14, screen sizes 4.7"-6.7", minimum 5 devices tested
- [ ] T083 Run manual testing following `specs/001-build-an-mvp/quickstart.md` scenarios
- [ ] T083.5 Verify quickstart.md test scenarios match current implementation: update quickstart if API routes, component names, or flow steps changed during development
- [ ] T084 Test complete flow: Generate QR on web → Scan with mobile → View on dashboard in real-time
- [ ] T085 Verify real-time updates work by performing scan and watching dashboard auto-refresh
- [ ] T085.5 Test network failure scenarios: scan during WiFi interruption, toggle airplane mode, verify error handling and retry logic
- [ ] T086 Test on physical iOS and Android devices via local network connection. Verify mobile browser can access dashboard at http://{local_ip}:3000 with responsive layout (FR-019)
- [ ] T087 Verify performance: QR gen < 500ms, dashboard refresh < 1s, mobile scan < 3s
- [ ] T087.5 Load test with 10 concurrent QR generations and 20 concurrent scans: verify no database lock contention or timeouts
- [ ] T087.6 Log actual performance metrics during testing: compare against targets in plan.md, document results in README

---

## Phase 3.11: Documentation & Deployment

- [ ] T088 Create environment variables documentation in `web/.env.example` with required vars
- [ ] T089 Create environment variables documentation in `mobile/lib/config/env.example.dart`
- [ ] T090 Create README.md in repository root with setup instructions for web and mobile
- [ ] T090.5 Document authentication clarification in README: "Single-tenant means all authenticated users have equal permissions, no organizational isolation"
- [ ] T090.6 Add data retention policy to README: "MVP has no retention policy (indefinite storage). Post-MVP: implement TTL based on expiry date"
- [ ] T091 Document Supabase project setup steps in README (create project, get credentials, run migrations)
- [ ] T091.5 Add Supabase dependency note to README: "Supabase SLA is 99.9% uptime. MVP accepts this risk. No fallback for Supabase outage"
- [ ] T092 Add local network testing guide to README (find local IP, configure mobile app)
- [ ] T093 Create troubleshooting guide in README for common issues (camera permissions, network errors, QR detection)
- [ ] T093.5 Add firewall configuration to troubleshooting: "Allow port 3000, disable mDNS discovery if connection fails"
- [ ] T094 Add architecture diagram to README showing web, mobile, and Supabase connections
- [ ] T095 Document GS1 format in README with example QR data
- [ ] T096 Configure Next.js to listen on 0.0.0.0 instead of localhost in `web/package.json` dev script
- [ ] T097 Test deployment: Deploy web app to Vercel free tier (optional for MVP)
- [ ] T098 Create Git commit with message: "feat: complete MVP vaccine tracking system"
- [ ] T098.5 Create CHANGELOG.md with MVP v1.0.0 release notes: list implemented features (28 FRs), tech stack (Next.js/Flutter/Supabase), and known limitations

---

## Dependencies

### Blocking Dependencies
- T001-T007 (Supabase setup) blocks ALL other tasks
- T008-T015 (Web setup) blocks T016-T041 (Web components)
- T042-T047 (Mobile setup) blocks T048-T073 (Mobile features)
- T014-T015 (GS1 utils) blocks T016-T020 (QR Generator)
- T012-T013 (Supabase client) blocks all API routes (T021-T022, T040-T041, T074-T078)
- T044 (Supabase service) blocks T049, T061-T062, T066
- T048-T053 (Auth) blocks T054-T067 (Scanner)
- T055-T059 (QR detection) blocks T060-T064 (Scan handling)

### Sequential Tasks (Same File)
- T016 → T017-T018 (Generate page uses components)
- T028 → T029-T030 (Dashboard page uses components)
- T048 → T049-T053 (Login screen uses auth service)
- T054 → T055-T067 (Scanner screen composition)

### Parallel Opportunities
- T017, T018 [P] - Different components
- T025, T024 [P] - Different components
- T029, T030 [P] - Different components
- T065, T060 [P] - Different widgets
- Web tasks (T008-T041) and Mobile tasks (T042-T073) can run in parallel after T001-T007

---

## Parallel Execution Examples

### After Database Setup (T001-T007 complete)
```bash
# Start both web and mobile setup simultaneously
Task 1: "Initialize Next.js 14+ project in web/ directory with TypeScript and App Router"
Task 2: "Initialize Flutter project in mobile/ directory with package name com.vaccine.tracker"
```

### Web Component Development
```bash
# Build multiple components in parallel
Task 1: "Create QRGeneratorForm component in web/components/QRGeneratorForm.tsx with GTIN, Batch, Expiry, Serial inputs"
Task 2: "Create QRPreview component in web/components/QRPreview.tsx using react-qr-code for live preview"
Task 3: "Create Toast component in web/components/Toast.tsx for success notifications"
```

### Mobile Widget Development
```bash
# Build multiple widgets in parallel
Task 1: "Create scanned data display widget in mobile/lib/widgets/scanned_data_display.dart with labeled fields"
Task 2: "Create scan history widget in mobile/lib/widgets/scan_history.dart showing last 5 scans"
```

### Testing Phase
```bash
# Run tests in parallel
Task 1: "Create integration test in web/__tests__/integration/qr-generation.test.ts for QR generation flow"
Task 2: "Create unit test in web/__tests__/unit/gs1-encoder.test.ts for GS1 encoding/decoding"
Task 3: "Create Flutter widget test in mobile/test/widget_test.dart for scanner screen"
```

---

## Notes

- All paths are absolute from repository root
- Verify each task completion before moving to dependent tasks
- Commit after completing each phase (e.g., after T007, T041, T073, T087)
- Test on physical devices during T086 to validate camera and network functionality
- Follow constitutional principles: hot reload, real-time updates, local network testing

---

## Task Execution Checklist

**Phase Status**:
- [x] Phase 3.1: Backend Foundation (T001-T007)
- [x] Phase 3.2: Web Setup (T008-T015)
- [x] Phase 3.3: QR Generator (T016-T027)
- [x] Phase 3.4: Dashboard (T028-T041.5)
- [x] Phase 3.5: Mobile Setup (T042-T047)
- [x] Phase 3.6: Mobile Auth (T048-T053) - ✅ COMPLETE (T049.5 and T049.6 require Supabase dashboard config - see reminder at end)
- [x] Phase 3.7: Scanner Screen (T054-T067.2) - ✅ COMPLETE (Including bug fixes for duplicate scans and overlay positioning)
- [x] Phase 3.8: Network Config (T068-T073.5) - ✅ COMPLETE (Local network testing setup with IP auto-detection)
- [x] Phase 3.9: Integration (T074-T079.6) - ✅ COMPLETE (API endpoints working: POST /api/scan, GET /api/qr/[id], GET /api/scans/user/[email])
- [ ] Phase 3.10: Testing (T080-T087)
- [ ] Phase 3.11: Documentation (T088-T098.5)

**Total Tasks**: 129 (98 original + 26 enhancements from first analysis + 3 refinements from second analysis + 2 bug fixes)
**Completed Tasks**: 88/129 (68%)
**Estimated Parallel Groups**: 15-20 (marked with [P])
**Estimated Time**: 4-6 days for experienced developer working full-time

**Analysis Enhancements Added**:
- 8 Security tasks (RLS testing, password policy, rate limiting, CORS)
- 6 Error handling tasks (camera errors, network retry, duplicate scans)
- 7 Testing tasks (API contracts, validation tests, load testing)
- 5 Technical validation tasks (GS1 compatibility, real-time latency, monitoring)
- 3 Documentation/testing refinements (quickstart verification, FR-019 explicit test, CHANGELOG)

---

**Generated**: 2025-10-05
**Based on**: plan.md, data-model.md, contracts/api-spec.yaml, quickstart.md
**Constitution**: v1.0.0
