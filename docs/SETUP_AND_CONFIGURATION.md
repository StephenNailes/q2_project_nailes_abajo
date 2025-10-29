# 🚀 EcoSustain - Complete Setup & Configuration Guide

> **Consolidated guide covering Firebase, Supabase, and Google Sign-In setup**

---

## Table of Contents
1. [Firebase Setup](#firebase-setup)
2. [Supabase Setup](#supabase-setup)
3. [Google Sign-In Configuration](#google-sign-in-configuration)
4. [Android Configuration](#android-configuration)
5. [Testing Your Setup](#testing-your-setup)

---

## Firebase Setup

### Step 1: Configure Firebase for Flutter

Run the FlutterFire configuration command:

```powershell
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart`
- Update Android and iOS configuration files
- Register apps for Android, iOS, and Web

### Step 2: Enable Firebase Services

Go to **Firebase Console**: https://console.firebase.google.com/project/eco-sustain-51b9b

#### A. Enable Authentication
1. Click **Build** → **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password**
5. Enable **Google Sign-In** (add support email)

#### B. Enable Firestore Database
1. Click **Build** → **Firestore Database**
2. Click **Create database**
3. **Start in test mode**
4. Choose location: **us-central**
5. Click **Enable**

#### C. Enable Firebase Storage
1. Click **Build** → **Storage**
2. Click **Get started**
3. **Start in test mode**
4. Click **Done**

### Step 3: Update Security Rules

#### Firestore Rules
Go to **Firestore Database** → **Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Submissions - users can read/write their own submissions
    match /submissions/{submissionId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Recycling history - users can read/write their own history
    match /recycling_history/{historyId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Eco tips - public read, admin write
    match /eco_tips/{tipId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

#### Storage Rules
Go to **Storage** → **Rules**:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile pictures
    match /profile_pictures/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Submission photos
    match /submissions/{userId}/{submissionId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Supabase Setup

### Step 1: Create Supabase Project

1. Go to: https://supabase.com/
2. Sign up with GitHub/Google
3. Click **New project**
4. Enter details:
   - Name: `ecosustain`
   - Database password: (create secure password)
   - Region: Choose closest to you
5. Click **Create new project** (takes ~2 minutes)

### Step 2: Get Your Credentials

1. Go to **Project Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://uxiticipaqsfpsvijbcn.supabase.co`
   - **Anon key**: `eyJhbGc...` (public key)

### Step 3: Create Database Schema

1. Go to **SQL Editor**
2. Click **New query**
3. Copy SQL from `supabase_schema.sql` in project root
4. Click **Run**

This creates:
- `user_profiles` table
- `submissions` table
- `recycling_history` table
- `eco_tips` table
- Security policies (RLS)
- Performance indexes

---

## Google Sign-In Configuration

### For Web (Already Configured) ✅

Web Client ID is already configured in `web/index.html`. No additional steps needed.

### For Android

#### Step 1: Get SHA-1 Fingerprint

```powershell
cd android
.\gradlew.bat signingReport
```

Look for output like:
```
SHA-1: 92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0
```

#### Step 2: Add SHA-1 to Firebase

1. Go to: https://console.firebase.google.com/project/eco-sustain-51b9b/settings/general
2. Scroll to "Your apps" → Android app (`com.example.eco_sustain`)
3. Click "Add fingerprint"
4. Paste SHA-1 fingerprint
5. Click "Save"

#### Step 3: Download New google-services.json

1. Download updated `google-services.json`
2. Replace file at: `android/app/google-services.json`

```powershell
# PowerShell command to replace file
Copy-Item -Path "C:\Users\MYPC\Downloads\google-services.json" -Destination "android\app\google-services.json" -Force
```

#### Step 4: Clean and Rebuild

```powershell
flutter clean
flutter pub get
flutter run
```

---

## Android Configuration

### Current Configuration

**Package Name**: `com.example.eco_sustain`

**Your SHA-1 Fingerprint** (Debug):
```
92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0
```

### For Release Build

When publishing to Play Store, generate release SHA-1:

```powershell
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload
```

Add this SHA-1 to Firebase Console as well.

---

## Testing Your Setup

### Test Firebase Connection

Run the app and check console:

```powershell
flutter run
```

**Expected Output:**
```
✅ Firebase initialized successfully
✅ Supabase initialized successfully
```

### Test Google Sign-In

1. Navigate to login screen
2. Click "Sign in with Google"
3. Google account picker should appear
4. Select account → Sign in successful
5. Navigate to `/home` screen

### Test Supabase Connection

1. Check Supabase Dashboard → Table Editor
2. You should see 4 tables with sample data
3. Try signing up with email/password
4. Check `user_profiles` table for new entry

---

## Troubleshooting

### Google Sign-In Issues

**Error: "Developer Error" or code 10**
- Solution: SHA-1 not added or wrong `google-services.json`
- Verify SHA-1 in Firebase Console
- Download fresh `google-services.json`

**Error: "Sign in failed"**
- Check internet connection
- Verify Google Sign-In enabled in Firebase
- Ensure correct `google-services.json` version

### Firebase Connection Issues

**Error: Firebase not initialized**
- Run `flutterfire configure`
- Ensure `firebase_options.dart` exists
- Check `lib/main.dart` has Firebase initialization

### Supabase Connection Issues

**Error: Invalid Supabase credentials**
- Verify URL and anon key in `lib/config/env_config.dart`
- Check project is active in Supabase Dashboard
- Ensure RLS policies are configured

---

## Quick Commands Reference

```powershell
# Configure Firebase
flutterfire configure

# Get SHA-1 fingerprint
cd android
.\gradlew.bat signingReport

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Build APK
flutter build apk --release

# Build AAB (Play Store)
flutter build appbundle --release

# Analyze code
flutter analyze

# Check setup
flutter doctor -v
```

---

## Configuration Summary

### Firebase Project
- **Project ID**: `eco-sustain-51b9b`
- **Project Number**: `851189435727`
- **Storage Bucket**: `eco-sustain-51b9b.firebasestorage.app`

### Supabase Project
- **Project URL**: `https://uxiticipaqsfpsvijbcn.supabase.co`
- **Project ID**: `uxiticipaqsfpsvijbcn`

### Android App
- **Package Name**: `com.example.eco_sustain`
- **Firebase App ID**: `1:851189435727:android:f580ac8729c44a5fff493a`

---

## What's Already Configured

- ✅ Firebase SDK installed
- ✅ Supabase package installed
- ✅ Google Sign-In package installed
- ✅ Firebase options generated
- ✅ Supabase credentials configured
- ✅ Authentication services ready
- ✅ Database services ready
- ✅ Storage services ready
- ✅ All data models created

---

## Next Steps After Setup

1. ✅ Test Google Sign-In on Android emulator
2. ✅ Test email/password authentication
3. ✅ Test submission creation
4. ✅ Test profile picture upload
5. ✅ Verify data in Firebase/Supabase dashboards
6. ✅ Deploy to production when ready

---

## Support Links

- **Firebase Console**: https://console.firebase.google.com/project/eco-sustain-51b9b
- **Supabase Dashboard**: https://supabase.com/dashboard/project/uxiticipaqsfpsvijbcn
- **Firebase Docs**: https://firebase.google.com/docs/flutter/setup
- **Supabase Docs**: https://supabase.com/docs/guides/getting-started/quickstarts/flutter

---

*Last Updated: October 30, 2025*
