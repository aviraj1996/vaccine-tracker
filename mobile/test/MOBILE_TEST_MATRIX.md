# Mobile Test Matrix

## Target Platforms

### iOS
- **Minimum Version**: iOS 12.0
- **Maximum Version**: iOS 17.0
- **Tested Versions**:
  - iOS 15.0 (iPhone 12)
  - iOS 16.5 (iPhone 14 Pro)
  - iOS 17.0 (iPhone 15)

### Android
- **Minimum Version**: Android 8.0 (API 26)
- **Maximum Version**: Android 14 (API 34)
- **Tested Versions**:
  - Android 10 (API 29)
  - Android 12 (API 31)
  - Android 13 (API 33)

## Screen Sizes

### Small Screens (4.7" - 5.5")
- iPhone SE (2nd gen) - 4.7" (750x1334)
- Pixel 4a - 5.8" (1080x2340)

### Medium Screens (5.5" - 6.1")
- iPhone 12/13 - 6.1" (1170x2532)
- Samsung Galaxy S21 - 6.2" (1080x2400)

### Large Screens (6.1" - 6.7")
- iPhone 14 Pro Max - 6.7" (1284x2778)
- Samsung Galaxy S23 Ultra - 6.8" (1440x3088)

## Minimum Testing Requirements

**Total Devices**: Minimum 5 physical devices across platforms

### Required Test Devices
1. **iPhone (iOS 15+)** - Medium screen (6.1")
2. **iPhone (iOS 17)** - Large screen (6.7")
3. **Android (API 29-31)** - Small to medium screen (5.5"-6.1")
4. **Android (API 32-34)** - Medium screen (6.1"-6.5")
5. **Android or iOS** - Large screen (6.5"-6.8")

## Testing Checklist

### Scanner Functionality
- [ ] Camera permissions granted correctly
- [ ] QR scanner detects GS1-formatted codes
- [ ] Scan success dialog displays correctly
- [ ] Scan error handling works properly
- [ ] Duplicate scan detection (3-second cooldown)
- [ ] Scanner overlay centered and visible
- [ ] Flashlight toggle works in low light
- [ ] Camera focus adjusts automatically

### Authentication
- [ ] Login with valid credentials
- [ ] Login error handling
- [ ] Logout confirmation dialog
- [ ] Session persistence across app restarts
- [ ] Auto-redirect after logout

### Network
- [ ] Scan records save to Supabase
- [ ] Real-time sync with dashboard
- [ ] Network error handling
- [ ] Retry logic (3 attempts)
- [ ] Offline detection and user feedback

### UI/UX
- [ ] Scan history displays last 5 scans
- [ ] Scanned data display shows all fields
- [ ] Responsive layout on all screen sizes
- [ ] Touch targets minimum 44x44 points (iOS) / 48x48 dp (Android)
- [ ] Text readable on all screen sizes
- [ ] No UI overflow or clipping
- [ ] Status bar safe area respected

### Performance
- [ ] App cold start < 3s
- [ ] Scanner initialization < 1s
- [ ] Scan processing < 500ms
- [ ] Hot reload < 1s (development)
- [ ] Memory usage < 150MB
- [ ] No frame drops during scanning

## Test Execution Results

### Current Testing Status (2025-10-08)

**Devices Tested**: 1/5 (20%)

| Device | OS Version | Screen Size | Status | Notes |
|--------|-----------|-------------|--------|-------|
| iPhone | iOS (latest) | 6.1" | ✅ PASS | All features working |
| Android | - | - | ⏳ PENDING | Not yet tested |
| Android | - | - | ⏳ PENDING | Not yet tested |
| iPhone | - | - | ⏳ PENDING | Not yet tested |
| Android/iOS | - | - | ⏳ PENDING | Not yet tested |

### Known Issues
- Widget tests require Supabase initialization (integration tests needed)
- Android platform not yet tested
- Multiple screen sizes not yet validated
- Performance metrics not yet collected

## Testing Instructions

### Physical Device Setup
1. Enable Developer Mode
   - iOS: Settings → General → VPN & Device Management
   - Android: Settings → About Phone → Tap "Build Number" 7 times
2. Connect device via USB
3. Trust development certificate (iOS) or enable USB debugging (Android)
4. Run `flutter devices` to verify connection
5. Run `flutter run` to install and launch app

### Manual Test Procedure
1. **Pre-test**:
   - Clear app data
   - Reset database to known state
   - Verify network connectivity
2. **Execute test scenarios** (see quickstart.md)
3. **Record results** in this document
4. **Capture screenshots** of any issues
5. **Log performance metrics** using Flutter DevTools

### Automated Tests
```bash
# Run all unit tests
flutter test test/unit/

# Run specific widget test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# Run on specific device
flutter test --device-id=<device_id>
```

## GS1 Parser Test Coverage

**Unit Tests**: 31 tests ✅ All passing

### Test Categories
- GS1 parsing (valid/invalid formats)
- Field extraction (GTIN, batch, expiry, serial)
- Date formatting (YYMMDD → YYYY-MM-DD)
- Error handling
- Edge cases (whitespace, different AI order)

## Next Steps
1. Test on Android devices (minimum 2 devices)
2. Test on additional iOS devices (different screen sizes)
3. Create widget tests with proper mocking
4. Add integration tests for end-to-end flows
5. Collect and document performance metrics
6. Test network failure scenarios thoroughly

## References
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [GS1 Standards](https://www.gs1.org/standards)
- [iOS Device Specifications](https://developer.apple.com/ios/device-specifications/)
- [Android API Levels](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels)
