# vaccine-tracker Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-10-08

## 🎯 Project Status: Phase 3.7 Complete (53% Overall)

**Current Phase:** 3.7 Scanner Screen ✅ Complete
**Next Phase:** 3.8 QR Generation Web Interface
**Overall Progress:** 67/127 tasks (53%)

## Active Technologies
- **Backend:** Supabase (PostgreSQL + Auth + Realtime)
- **Web:** Next.js 14.2.22, TypeScript 5.x, React 18, Tailwind CSS
- **Mobile:** Flutter 3.x, Dart 3.x, Provider, mobile_scanner v7.1.2
- **QR:** qrcode.js (web), mobile_scanner (mobile)
- **Integration:** Supabase JS SDK v2.x, supabase_flutter v2.0.0

## Project Structure
```
vaccine-tracker/
├── supabase/          # Database schema, migrations, seed data
├── web/               # Next.js 14 app (dashboard, QR generation)
├── mobile/            # Flutter app (QR scanner)
├── specs/             # Feature specifications and plans
└── *.md               # Documentation (setup, testing, status)
```

## Commands

### Web (Next.js)
```bash
cd web
npm install              # Install dependencies
npm run dev              # Start dev server (localhost:3000)
npm run build            # Production build
npm run lint             # Lint TypeScript/React
```

### Mobile (Flutter)
```bash
cd mobile
flutter pub get          # Install dependencies
flutter run              # Run on connected device
flutter build ios        # Build iOS app
flutter build apk        # Build Android APK
flutter analyze          # Analyze Dart code
```

### Database (Supabase)
```bash
cd supabase
supabase start           # Start local Supabase
supabase db push         # Push migrations to cloud
supabase db reset        # Reset local DB with seed data
```

### Verification Script
```bash
.specify/scripts/bash/verify-scan-records.sh  # Verify database records
```

## Code Style

### TypeScript/JavaScript (Next.js)
- Follow Next.js 14 App Router conventions
- Use TypeScript strict mode
- Functional components with hooks
- ESLint + Prettier for formatting

### Dart (Flutter)
- Follow official Dart style guide
- Use Provider for state management
- Stateless widgets where possible
- async/await for asynchronous operations

## Recent Changes (2025-10-08)

### ✅ Phase 3.7: Scanner Screen (COMPLETE)
**Implemented:**
- Full QR scanner with mobile_scanner integration
- Camera viewfinder with overlay and instructions
- GS1 QR code parsing and validation
- Database lookup and scan event recording
- Success/error dialogs with user feedback
- Haptic feedback on scan detection
- Scan history display (last 5 scans)
- Flashlight toggle for low light
- Network retry logic (3 attempts)
- User authentication integration

**Tested:**
- ✅ iPhone (iOS) - Full functionality verified
- ✅ Database integration - Scan recorded successfully
- ✅ Real-time sync - Scan appears in dashboard
- ⏳ Android - Not yet tested

**Bug Fixed:**
- Loading screen persisted after success dialog dismissal
- Fixed by moving state update outside dialog callback

**Files Modified:**
- `mobile/lib/screens/scanner_screen.dart` (main scanner logic)
- `mobile/lib/services/scan_service.dart` (scan event management)
- `mobile/lib/widgets/qr_scanner.dart` (camera integration)
- `mobile/lib/widgets/scanned_data_display.dart` (data display)
- `mobile/lib/widgets/scan_history.dart` (history view)

**Documentation Added:**
- `PHASE_3_7_IMPLEMENTATION_GUIDE.md` (updated with test results)
- `PHASE_3_7_TESTING_GUIDE.md` (step-by-step testing instructions)
- `TEST_PLAN_PHASE_3_7.md` (comprehensive test plan with 45 test cases)
- `PROJECT_STATUS.md` (overall project status and metrics)

### 🔄 Previous Phases (Complete)
- ✅ Phase 3.1: Backend Foundation (Supabase setup)
- ✅ Phase 3.2: Web Project Setup (Next.js scaffold)
- ✅ Phase 3.3: Mobile Project Setup (Flutter scaffold)
- ✅ Phase 3.4: Models & Utilities (GS1 parser, data models)
- ✅ Phase 3.5: Core Services (Supabase integration)
- ✅ Phase 3.6: Authentication (Login/Logout on mobile + web)

### ⏳ Next Phase: 3.8 QR Generation Web Interface
**Upcoming Tasks:**
- Web form for QR generation (GTIN, Batch, Expiry, Serial)
- QR code image generation with qrcode.js
- Database integration for QR creation
- QR list view with search/filter
- Download QR as PNG/SVG

## Testing Guidelines

### Before Testing
1. Verify Supabase project is active
2. Check `.env` files have correct credentials
3. Ensure dependencies are installed (`flutter pub get`, `npm install`)

### Mobile Testing
1. Connect physical device (iOS or Android)
2. Run `flutter run` from `mobile/` directory
3. Grant camera permissions when prompted
4. Test scanning with real QR codes from web dashboard

### Web Testing
1. Run `npm run dev` from `web/` directory
2. Open http://localhost:3000
3. Test login/logout flow
4. Generate QR codes (Phase 3.8+)

### Database Verification
```bash
# Run verification script
.specify/scripts/bash/verify-scan-records.sh

# Check Supabase Dashboard
# https://app.supabase.com → Your Project → Table Editor
```

## Known Issues & Limitations

### Current Limitations
1. No duplicate scan detection (same QR can be scanned multiple times)
2. No offline mode (requires internet connection)
3. Android platform not yet tested (iOS only)
4. Some error scenarios simulated (not physically tested)

### Technical Debt
1. Print statements in code (lint warnings - non-critical)
2. Test file references non-existent MyApp class
3. Constants not in lowerCamelCase in gs1_parser.dart
4. No unit tests (only integration testing performed)

## Deployment Notes

### iOS Deployment
- Requires Apple Developer account for device testing
- Code signing configured in Xcode
- Camera permission configured in Info.plist
- Tested on iPhone (latest iOS)

### Android Deployment
- Camera permission configured in AndroidManifest.xml
- USB debugging enabled for testing
- APK available via `flutter build apk`

### Web Deployment
- Ready for Vercel/Netlify deployment
- Environment variables needed: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY

### Database (Supabase)
- Cloud project: bsdpgfhthdkuwihoomdk
- Region: Auto (closest)
- 20 QR codes in database
- 4 scan events recorded

## Support & Documentation

### Key Documents
- `SETUP_INSTRUCTIONS.md` - Initial setup guide
- `PHASE_3_7_IMPLEMENTATION_GUIDE.md` - Scanner implementation
- `PHASE_3_7_TESTING_GUIDE.md` - Testing instructions
- `TEST_PLAN_PHASE_3_7.md` - Complete test results
- `PROJECT_STATUS.md` - Overall project status

### External Resources
- Supabase: https://supabase.com/docs
- Flutter: https://docs.flutter.dev
- Next.js: https://nextjs.org/docs
- GS1 Standards: https://www.gs1.org/standards

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->