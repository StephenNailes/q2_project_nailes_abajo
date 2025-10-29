# 💻 EcoSustain - Developer Guide

> **Quick reference for development, commands, and common tasks**

---

## Table of Contents
1. [Quick Start](#quick-start)
2. [Development Commands](#development-commands)
3. [Project Structure](#project-structure)
4. [Common Tasks](#common-tasks)
5. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Prerequisites
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Firebase CLI
- Git

### Initial Setup

```powershell
# Clone repository
git clone https://github.com/StephenNailes/q2_project_nailes_abajo.git
cd Eco-Sustain-Flutter-App

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```

---

## Development Commands

### Basic Commands

```powershell
# Install dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Hot reload (during development)
# Press 'r' in terminal

# Hot restart (full restart)
# Press 'R' in terminal
```

### Build Commands

```powershell
# Build APK (for testing)
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release

# Build for debug
flutter build apk --debug

# Build for specific flavor (if configured)
flutter build apk --flavor production --release
```

### Code Quality

```powershell
# Analyze code
flutter analyze

# Analyze without fatal info warnings
flutter analyze --no-fatal-infos

# Format code
dart format .

# Fix formatting issues
dart format --fix .

# Check for issues
flutter doctor

# Verbose doctor info
flutter doctor -v
```

### Clean & Debug

```powershell
# Clean build files
flutter clean

# Complete clean and rebuild
flutter clean
Remove-Item -Recurse -Force build
flutter pub get
flutter run

# Clean Gradle cache (Android)
cd android
.\gradlew.bat clean
cd ..
```

### Firebase Commands

```powershell
# Login to Firebase
firebase login

# List Firebase projects
firebase projects:list

# Use specific project
firebase use eco-sustain-51b9b

# Configure Firebase for Flutter
flutterfire configure

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

### Android Specific

```powershell
# Generate SHA-1 fingerprint (debug)
cd android
.\gradlew.bat signingReport
cd ..

# Build Android app
flutter build apk --release

# Install APK on device
adb install build\app\outputs\flutter-apk\app-release.apk

# View Android logs
adb logcat
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── routes/
│   └── app_router.dart         # Go Router configuration
├── auth/
│   ├── login_screen.dart       # Login screen
│   └── register_screen.dart    # Registration screen
├── screen/
│   ├── dashboard_screen.dart   # Home dashboard
│   ├── profile_screen.dart     # User profile
│   ├── submission_screen.dart  # Submission entry point
│   ├── eco_tips_screen.dart    # Eco tips list
│   ├── settings_screen.dart    # Settings menu
│   ├── edit_profile_screen.dart
│   ├── change_password_screen.dart
│   └── manage_email_screen.dart
├── components/
│   ├── eco_bottom_nav.dart     # Bottom navigation bar
│   ├── dashboard/              # Dashboard components
│   ├── submission/             # 5-step wizard components
│   ├── ecotips/                # Eco tips components
│   └── learninghub/            # Learning hub components
├── services/
│   ├── firebase_auth_service.dart
│   ├── firebase_storage_service.dart
│   └── supabase_service.dart
├── models/
│   ├── user_model.dart
│   ├── submission_model.dart
│   ├── recycling_history_model.dart
│   └── eco_tip_model.dart
├── config/
│   └── env_config.dart         # Environment configuration
└── assets/
    └── images/                 # Image assets
```

---

## Common Tasks

### Adding a New Screen

1. Create screen file in `lib/screen/`
2. Add route to `lib/routes/app_router.dart`
3. If using bottom nav, add `EcoBottomNavBar(currentIndex: N)`
4. Apply gradient background if main screen

Example:
```dart
// 1. Create lib/screen/new_screen.dart
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Screen')),
      body: Container(...),
      bottomNavigationBar: EcoBottomNavBar(currentIndex: 0),
    );
  }
}

// 2. Add to app_router.dart
GoRoute(
  path: '/new',
  builder: (context, state) => NewScreen(),
),
```

### Adding a New Component

1. Create component file in `lib/components/<feature>/`
2. Follow naming convention: `<feature>_<component>.dart`
3. Import and use in screens

Example:
```dart
// lib/components/dashboard/new_card.dart
class NewCard extends StatelessWidget {
  final String title;
  
  const NewCard({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(title),
    );
  }
}
```

### Adding Firebase Authentication

```dart
// Import service
import 'package:eco_sustain/services/firebase_auth_service.dart';

// Use in widget
final _authService = FirebaseAuthService();

Future<void> _login() async {
  try {
    final user = await _authService.loginWithEmail(email, password);
    if (user != null) {
      context.go('/home');
    }
  } catch (e) {
    // Show error
  }
}
```

### Adding Supabase Database Operation

```dart
// Import service
import 'package:eco_sustain/services/supabase_service.dart';

// Use in widget
final _supabaseService = SupabaseService();

Future<void> _loadData() async {
  try {
    final profile = await _supabaseService.getUserProfile(userId);
    setState(() {
      _userProfile = profile;
    });
  } catch (e) {
    // Handle error
  }
}
```

### Uploading Images to Firebase Storage

```dart
import 'package:eco_sustain/services/firebase_storage_service.dart';
import 'package:image_picker/image_picker.dart';

final _storageService = FirebaseStorageService();
final _picker = ImagePicker();

Future<void> _uploadImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final url = await _storageService.uploadProfilePicture(file, userId);
    // Update profile with URL
  }
}
```

---

## Troubleshooting

### Common Issues

#### Issue: "Firebase not initialized"

**Solution:**
```powershell
flutterfire configure
flutter clean
flutter pub get
flutter run
```

#### Issue: "Google Sign-In not working on Android"

**Solution:**
1. Get SHA-1 fingerprint: `cd android && .\gradlew.bat signingReport`
2. Add to Firebase Console
3. Download new `google-services.json`
4. Replace in `android/app/`
5. Rebuild: `flutter clean && flutter run`

#### Issue: "Supabase connection failed"

**Solution:**
1. Check `lib/config/env_config.dart` has correct URL and key
2. Verify Supabase project is active
3. Check RLS policies are configured
4. Test connection in Supabase Dashboard

#### Issue: "Build failed with Gradle error"

**Solution:**
```powershell
cd android
.\gradlew.bat clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### Issue: "Hot reload not working"

**Solution:**
- Use Hot Restart (press 'R' instead of 'r')
- Or restart the app completely: `flutter run`

#### Issue: "Package version conflict"

**Solution:**
```powershell
flutter pub upgrade --major-versions
flutter pub get
```

---

## Code Style Guide

### Naming Conventions

```dart
// Classes: PascalCase
class UserProfile { }

// Files: snake_case
user_profile_screen.dart

// Variables: camelCase
final userName = 'John';

// Constants: camelCase
const maxRetries = 3;

// Private members: _camelCase
String _privateVariable;
```

### Widget Structure

```dart
class MyScreen extends StatelessWidget {
  // 1. Fields
  final String title;
  
  // 2. Constructor
  const MyScreen({required this.title});
  
  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
  
  // 4. Private methods
  void _handleSubmit() { }
}
```

### Design Patterns

**Use StatefulWidget when:**
- Managing local state
- Handling user input
- Loading data asynchronously

**Use StatelessWidget when:**
- Displaying static content
- No state changes needed
- Pure presentation components

---

## Testing

### Run Tests

```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Write Widget Tests

```dart
testWidgets('Login button shows loading', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  final button = find.text('Login');
  await tester.tap(button);
  await tester.pump();
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## Git Workflow

```powershell
# Check status
git status

# Stage changes
git add .

# Commit with message
git commit -m "feat: add profile picture upload"

# Push to remote
git push origin main

# Pull latest changes
git pull origin main

# Create new branch
git checkout -b feature/new-feature

# Merge branch
git checkout main
git merge feature/new-feature
```

---

## Useful Resources

### Documentation
- **Flutter Docs**: https://docs.flutter.dev/
- **Firebase Docs**: https://firebase.google.com/docs/flutter/setup
- **Supabase Docs**: https://supabase.com/docs/guides/getting-started/quickstarts/flutter
- **Go Router**: https://pub.dev/packages/go_router

### Project Links
- **Firebase Console**: https://console.firebase.google.com/project/eco-sustain-51b9b
- **Supabase Dashboard**: https://supabase.com/dashboard/project/uxiticipaqsfpsvijbcn
- **GitHub Repo**: https://github.com/StephenNailes/q2_project_nailes_abajo

---

## Environment Variables

### Configuration Files

**`lib/config/env_config.dart`**:
```dart
static const bool useFirebase = true;
static const bool useSupabase = true;
static const String supabaseUrl = 'https://uxiticipaqsfpsvijbcn.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

**`android/app/google-services.json`**: Firebase configuration (auto-generated)

**`lib/firebase_options.dart`**: Firebase options (auto-generated by flutterfire)

---

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilding entire trees** - use keys and const widgets
3. **Lazy load images** with `CachedNetworkImage`
4. **Use ListView.builder** for long lists
5. **Profile your app** with Flutter DevTools
6. **Minimize network requests** - cache data locally
7. **Compress images** before uploading

---

*Last Updated: October 30, 2025*
