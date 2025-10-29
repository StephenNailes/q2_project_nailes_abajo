# EcoSustain Backend Integration - Command Reference

## 🔥 Firebase Setup Commands

### Initial Setup
```powershell
# Login to Firebase (opens browser)
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
# (Generates lib/firebase_options.dart)
flutterfire configure

# Alternative path if command not found:
C:\Users\MYPC\AppData\Local\Pub\Cache\bin\flutterfire configure
```

### Useful Firebase Commands
```powershell
# List your Firebase projects
firebase projects:list

# Use a specific project
firebase use YOUR_PROJECT_ID

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules  
firebase deploy --only storage
```

---

## 🐘 Supabase Setup

### Web Dashboard URLs
- **Dashboard**: https://supabase.com/dashboard
- **Create Project**: https://supabase.com/dashboard/projects
- **Project Settings**: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api

### Get Credentials
1. Go to Project Settings > API
2. Copy:
   - Project URL: `https://xxxxx.supabase.co`
   - Anon key: `eyJhbGc...` (public key)

---

## 📱 Flutter Commands

### Dependencies
```powershell
# Install dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated

# Add a package
flutter pub add package_name
```

### Build & Run
```powershell
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d DEVICE_ID

# Run in release mode
flutter run --release

# Hot reload (during development)
# Press 'r' in terminal

# Hot restart (full restart)
# Press 'R' in terminal
```

### Clean & Debug
```powershell
# Clean build files
flutter clean

# Analyze code
flutter analyze

# Check for issues
flutter doctor

# Verbose doctor info
flutter doctor -v
```

### Build APK/AAB
```powershell
# Build APK (for testing)
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release

# Build for debug
flutter build apk --debug
```

---

## 🔑 Android Signing (for Google Sign-In)

### Generate SHA-1 Fingerprint
```powershell
# Navigate to android folder
cd android

# Generate debug SHA-1
./gradlew signingReport

# For Windows (PowerShell)
.\gradlew.bat signingReport

# Look for SHA-1 under "Variant: debug"
# Copy and paste into Firebase Console
# Settings > Your apps > Android app > Add fingerprint
```

---

## 🗄️ Firestore Security Rules

### Update Rules in Console
1. Go to Firebase Console
2. Firestore Database > Rules
3. Paste rules from `SETUP_GUIDE.md`
4. Click "Publish"

### Or Deploy via CLI
```powershell
# Create firestore.rules file in project root
# Then deploy:
firebase deploy --only firestore:rules
```

---

## 🛠️ Troubleshooting Commands

### Firebase Issues
```powershell
# Reconfigure Firebase
flutterfire configure

# Check Firebase projects
firebase projects:list

# Logout and login again
firebase logout
firebase login
```

### Flutter Issues
```powershell
# Complete clean and rebuild
flutter clean
rm -rf build/
flutter pub get
flutter run

# For Windows PowerShell:
flutter clean
Remove-Item -Recurse -Force build
flutter pub get
flutter run
```

### Gradle Issues (Android)
```powershell
cd android
./gradlew clean

# For Windows:
.\gradlew.bat clean

cd ..
flutter clean
flutter pub get
```

---

## 📦 Package Management

### Current Packages in Project
```yaml
# Firebase
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
firebase_storage: ^12.3.4
google_sign_in: ^6.2.2

# Supabase
supabase_flutter: ^2.8.0

# Other
shared_preferences: ^2.3.3
image_picker: ^1.0.7
go_router: ^16.2.1
```

---

## 🔧 Environment Configuration

### File: `lib/config/env_config.dart`

```dart
// Enable/disable backends
static const bool useFirebase = true;
static const bool useSupabase = false;

// Supabase credentials (if using Supabase)
static const String supabaseUrl = 'YOUR_URL_HERE';
static const String supabaseAnonKey = 'YOUR_KEY_HERE';
```

---

## 📱 Testing

### Run on Emulator
```powershell
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch EMULATOR_ID

# Run app
flutter run
```

### Run on Physical Device
```powershell
# Enable USB debugging on Android
# Settings > Developer Options > USB Debugging

# Check connected devices
flutter devices

# Run
flutter run
```

---

## 🚀 Quick Start Checklist

```
[ ] Run: firebase login
[ ] Run: dart pub global activate flutterfire_cli
[ ] Run: flutterfire configure
[ ] Update: lib/main.dart (uncomment firebase_options import)
[ ] Create: Firebase project in console
[ ] Enable: Authentication (Email + Google)
[ ] Enable: Firestore Database
[ ] Enable: Storage
[ ] Update: Security rules
[ ] Optional: Create Supabase project
[ ] Optional: Update env_config.dart
[ ] Run: flutter pub get
[ ] Run: flutter run
```

---

## 📞 Support Links

- **Firebase Console**: https://console.firebase.google.com/
- **Firebase Docs**: https://firebase.google.com/docs/flutter/setup
- **Supabase Dashboard**: https://supabase.com/dashboard
- **Supabase Docs**: https://supabase.com/docs/guides/getting-started/quickstarts/flutter
- **Flutter Docs**: https://docs.flutter.dev/

---

## 💡 Quick Tips

1. **Always run `flutter pub get` after changing `pubspec.yaml`**
2. **Use `flutter clean` if you encounter weird build errors**
3. **Check `flutter doctor` to ensure everything is set up**
4. **Keep Firebase CLI and FlutterFire CLI updated**
5. **Test on a real device for Google Sign-In (emulator may have issues)**
6. **Add SHA-1 fingerprint to Firebase for Google Sign-In to work**

---

**Ready to go? Run the commands and let me know if you need help! 🚀**
