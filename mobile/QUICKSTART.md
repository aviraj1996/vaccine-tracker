# Flutter Mobile App - Quick Start Guide

## ⚡ Fast Setup (5 minutes)

### 1. Install Flutter

**macOS**:
```bash
brew install --cask flutter
```

**Other platforms**: https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter --version
flutter doctor
```

### 2. Install Dependencies

```bash
cd /Users/aviraj/vaccine-tracker/mobile
flutter pub get
```

### 3. Configure Supabase

**Option A: Edit env.dart directly**

Open `lib/config/env.dart` and update line 12:
```dart
defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE', // <- Replace this
```

**Option B: Use .env file**

Edit `.env` file:
```env
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Get your anon key**:
1. Go to https://app.supabase.com/project/bsdpgfththdkuwihoomdk/settings/api
2. Copy "anon public" key
3. Paste into env.dart or .env

### 4. Run the App

```bash
# List available devices
flutter devices

# Run on first available device
flutter run

# Or specify device
flutter run -d <device_id>
```

That's it! 🎉

---

## 📱 What You'll See

The app will launch with a placeholder homepage showing:
- ✅ Configuration status (will show green checkmark after step 3)
- 📋 Next steps for development
- 🔧 Phase 3.5 completion status

---

## 🚧 Next Development Steps

### Phase 3.6 - Authentication (Next)
Implement login screen and Supabase authentication.

### Phase 3.7 - Scanner Screen
Add camera-based QR code scanning functionality.

### Phase 3.8 - Network Config
Configure local network access to web dashboard.

---

## 🐛 Troubleshooting

**"Flutter not found"**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
# Or install via Homebrew
brew install --cask flutter
```

**"Configuration not valid" message in app**
- Make sure you updated the Supabase anon key (Step 3)
- Check that the key starts with "eyJ..."
- Restart the app after updating

**Dependencies not resolving**
```bash
flutter clean
flutter pub get
```

**Can't run on iOS simulator**
- Make sure Xcode is installed
- Open Xcode and accept license agreement
- Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

**Camera permission error**
- Camera permissions are already configured in AndroidManifest.xml and Info.plist
- If still having issues, uninstall app and reinstall

---

## 📚 Full Documentation

See [README.md](README.md) for complete setup instructions and troubleshooting.

---

**Phase 3.5 Status**: ✅ Complete
**Ready for**: Phase 3.6 - Authentication & Navigation
