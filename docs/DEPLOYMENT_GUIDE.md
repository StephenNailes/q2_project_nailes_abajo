# 🚀 EcoSustain - Deployment Guide

> **Complete guide for deploying to production (Google Play Store and Web)**

---

## Table of Contents
1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Android Deployment](#android-deployment)
3. [Web Deployment](#web-deployment)
4. [Post-Deployment](#post-deployment)

---

## Pre-Deployment Checklist

### Code Quality
- [ ] Run `flutter analyze` - no errors
- [ ] Run `flutter test` - all tests pass
- [ ] Remove all debug prints and logs
- [ ] Update version number in `pubspec.yaml`
- [ ] Test on multiple devices/screen sizes
- [ ] Test all user flows end-to-end

### Backend Configuration
- [ ] Firebase production project set up
- [ ] Supabase production database configured
- [ ] Security rules reviewed and tightened
- [ ] RLS policies configured for production
- [ ] Environment variables set for production
- [ ] API keys secured (not in source code)

### Assets & Content
- [ ] All images optimized
- [ ] App icon finalized
- [ ] Splash screen configured
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] App description and screenshots ready

---

## Android Deployment

### Step 1: Create Keystore

Generate a release keystore for signing your app:

```powershell
keytool -genkey -v -keystore c:\Users\MYPC\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Save these details securely:**
- Keystore password
- Key alias: `upload`
- Key password

### Step 2: Configure key.properties

Create `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=C:/Users/MYPC/upload-keystore.jks
```

**Add to `.gitignore`**:
```
android/key.properties
*.jks
```

### Step 3: Update build.gradle

**`android/app/build.gradle.kts`** should already have signing config. Verify it includes:

```kotlin
android {
    ...
    signingConfigs {
        getByName("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### Step 4: Update App Information

**`android/app/src/main/AndroidManifest.xml`**:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.eco_sustain">
    
    <application
        android:label="EcoSustain"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Update label with production name -->
    </application>
</manifest>
```

**`pubspec.yaml`**:

```yaml
name: eco_sustain
description: E-waste recycling management app
version: 1.0.0+1  # Update version before each release
```

### Step 5: Get Production SHA-1

```powershell
keytool -list -v -keystore c:\Users\MYPC\upload-keystore.jks -alias upload
```

**Add to Firebase Console**:
1. Go to Project Settings
2. Add release SHA-1 fingerprint
3. Download new `google-services.json`
4. Replace in `android/app/`

### Step 6: Build Release APK/AAB

**Build APK** (for testing):
```powershell
flutter build apk --release
```

**Build AAB** (for Play Store):
```powershell
flutter build appbundle --release
```

**Output locations**:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Step 7: Test Release Build

```powershell
# Install APK on device
adb install build\app\outputs\flutter-apk\app-release.apk

# Test all features:
# - Google Sign-In
# - Email/Password auth
# - Photo uploads
# - Submissions
# - Profile updates
```

### Step 8: Google Play Console Setup

1. **Create App** in Play Console: https://play.google.com/console/
   - App name: "EcoSustain"
   - Default language: English
   - App or Game: App
   - Free or Paid: Free

2. **App Content**:
   - Privacy Policy URL (required)
   - App access (all features available)
   - Ads declaration
   - Content rating questionnaire
   - Target audience and content
   - News app declaration

3. **Store Listing**:
   - App name: "EcoSustain"
   - Short description (80 chars)
   - Full description (4000 chars)
   - App icon (512x512 PNG)
   - Feature graphic (1024x500)
   - Screenshots (at least 2):
     - Phone: 16:9 or 9:16, 320-3840px
     - 7" tablet (optional)
     - 10" tablet (optional)

4. **Upload AAB**:
   - Go to Production → Releases
   - Create new release
   - Upload `app-release.aab`
   - Add release notes
   - Review and rollout

---

## Web Deployment

### Step 1: Build Web Release

```powershell
flutter build web --release
```

**Output**: `build/web/` directory

### Step 2: Configure Firebase Hosting (Recommended)

```powershell
# Install Firebase CLI (if not already)
npm install -g firebase-tools

# Login
firebase login

# Initialize hosting
firebase init hosting
```

**Select options**:
- Public directory: `build/web`
- Single-page app: Yes
- Automatic builds: No

**`firebase.json`**:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### Step 3: Deploy to Firebase

```powershell
# Build web app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

**Your app will be live at**:
```
https://eco-sustain-51b9b.web.app
https://eco-sustain-51b9b.firebaseapp.com
```

### Step 4: Custom Domain (Optional)

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Enter your domain (e.g., ecosustain.com)
4. Follow DNS configuration steps
5. Wait for SSL certificate provisioning

---

## Alternative Web Hosting

### Option 1: Netlify

```powershell
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

### Option 2: Vercel

```powershell
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod build/web
```

### Option 3: GitHub Pages

1. Build web app: `flutter build web --release`
2. Copy `build/web` contents to your GitHub Pages repo
3. Commit and push
4. Enable GitHub Pages in repo settings

---

## Post-Deployment

### Monitoring

**Firebase Crashlytics** (Android):
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^4.0.0
```

```dart
// Initialize in main.dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
```

**Firebase Analytics**:
```dart
// Track events
await FirebaseAnalytics.instance.logEvent(
  name: 'submission_created',
  parameters: {'item_type': 'phone'},
);
```

### Version Updates

**Update version in `pubspec.yaml`**:
```yaml
version: 1.1.0+2  # 1.1.0 = version name, 2 = version code
```

**Build and upload new release**:
```powershell
flutter build appbundle --release
```

### Rollback (if needed)

**Google Play Console**:
1. Go to Production → Releases
2. Click "Create new release"
3. Upload previous AAB version
4. Rollout to production

**Firebase Hosting**:
```powershell
firebase hosting:rollback
```

---

## Production Checklist

### Before Launch
- [ ] Test on real devices (not just emulators)
- [ ] Test all authentication methods
- [ ] Test all user flows
- [ ] Verify all API endpoints
- [ ] Check network error handling
- [ ] Test offline functionality
- [ ] Verify data persistence
- [ ] Test on slow networks
- [ ] Check battery usage
- [ ] Review app permissions

### Security
- [ ] Remove debug logs
- [ ] Secure API keys
- [ ] Enable ProGuard (Android obfuscation)
- [ ] Update Firebase security rules
- [ ] Update Supabase RLS policies
- [ ] Enable HTTPS only
- [ ] Implement rate limiting
- [ ] Add input validation
- [ ] Sanitize user data

### Performance
- [ ] Optimize images
- [ ] Minimize app size
- [ ] Reduce network calls
- [ ] Implement caching
- [ ] Lazy load components
- [ ] Profile memory usage
- [ ] Test on low-end devices

### Compliance
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] GDPR compliance (if EU users)
- [ ] COPPA compliance (if under 13)
- [ ] Data retention policy
- [ ] User data deletion flow
- [ ] Cookie consent (web)

---

## Maintenance

### Regular Tasks
- Monitor crash reports weekly
- Review analytics monthly
- Update dependencies quarterly
- Security audits quarterly
- Backup database weekly
- Test critical flows weekly

### User Feedback
- Monitor Play Store reviews
- Respond to user issues
- Collect feature requests
- Track bug reports
- Update FAQ/Help content

---

## Useful Commands

```powershell
# Check app size
flutter build apk --analyze-size

# Profile app performance
flutter run --profile

# Generate icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create

# Clean and rebuild
flutter clean && flutter pub get && flutter build apk --release
```

---

## Support Resources

- **Play Console**: https://play.google.com/console/
- **Firebase Console**: https://console.firebase.google.com/
- **App Distribution**: https://appdistribution.firebase.dev/
- **Flutter Docs**: https://docs.flutter.dev/deployment

---

*Last Updated: October 30, 2025*
