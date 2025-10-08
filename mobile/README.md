# Vaccine Tracker Mobile App

Flutter-based mobile application for scanning vaccine QR codes.

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- iOS development: Xcode 14+ (for iOS development)
- Android development: Android Studio with Android SDK

## Installation

### 1. Install Flutter

If you haven't installed Flutter yet, follow the official guide:
https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter --version
flutter doctor
```

### 2. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 3. Configure Environment

Update `lib/config/env.dart` with your Supabase credentials:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
```

Or use `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
# Edit .env with your credentials
```

### 4. Platform-Specific Setup

#### iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Update `ios/Runner/Info.plist` with camera permission:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to scan vaccine QR codes</string>
   ```
3. Set deployment target to iOS 12.0 or higher

#### Android Setup

1. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```
2. Set `minSdkVersion` to 21 in `android/app/build.gradle`

## Running the App

### Development

```bash
# Run on connected device or emulator
flutter run

# Run with hot reload
flutter run --hot

# Run on specific device
flutter devices
flutter run -d <device_id>
```

### Production Build

```bash
# Android APK
flutter build apk --release

# iOS IPA (requires Mac + Xcode)
flutter build ios --release
```

## Project Structure

```
mobile/
├── lib/
│   ├── config/          # Environment configuration
│   │   └── env.dart
│   ├── models/          # Data models
│   │   ├── qr_code.dart
│   │   └── scan_event.dart
│   ├── screens/         # UI screens (Phase 3.6+)
│   ├── services/        # Business logic
│   │   └── supabase_service.dart
│   ├── utils/           # Utilities
│   │   └── gs1_parser.dart
│   ├── widgets/         # Reusable widgets (Phase 3.7+)
│   └── main.dart        # App entry point
├── pubspec.yaml         # Dependencies
├── .env                 # Environment variables
└── README.md            # This file
```

## Features Implemented

### Phase 3.5: Mobile Setup ✅
- [x] Flutter project initialization
- [x] Supabase integration
- [x] Data models (QRCode, ScanEvent)
- [x] GS1 parser utility
- [x] Environment configuration

### Phase 3.6: Authentication (TODO)
- [ ] Login screen
- [ ] Supabase auth integration
- [ ] State management with Provider

### Phase 3.7: Scanner Screen (TODO)
- [ ] Camera integration
- [ ] QR code detection
- [ ] Scan recording
- [ ] Scan history

## Testing

### Run Tests

```bash
flutter test
```

### Run Widget Tests

```bash
flutter test test/widget_test.dart
```

## Troubleshooting

### Common Issues

**Flutter not found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Dependencies not resolving**
```bash
flutter clean
flutter pub get
```

**Camera not working**
- Verify permissions in Info.plist (iOS) or AndroidManifest.xml (Android)
- Test on physical device (camera doesn't work in simulator)

**Supabase connection failed**
- Check credentials in `lib/config/env.dart`
- Verify network connectivity
- Check Supabase project status

## Development

### Hot Reload
Press `r` in terminal or save file to trigger hot reload

### Debug Mode
```bash
flutter run --debug
```

### Release Mode
```bash
flutter run --release
```

## Contributing

This is an MVP project. For production use:
1. Add proper error handling
2. Implement offline support
3. Add comprehensive testing
4. Set up CI/CD pipeline
5. Add analytics and crash reporting

## License

MIT License - See LICENSE file for details

## Next Steps

1. Complete Phase 3.6: Authentication & Navigation
2. Complete Phase 3.7: Scanner Screen
3. Complete Phase 3.8: Network Configuration
4. Test on physical devices
5. Integration testing with web dashboard

---

**Phase 3.5 Status**: ✅ Complete
**Next Phase**: 3.6 - Authentication & Navigation
