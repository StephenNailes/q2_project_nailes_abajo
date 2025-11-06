# API Key Security Guide

## ✅ Security Status: PROTECTED

This document explains how API keys are protected in the TechSustain app and how to set up the project securely.

## Protected API Keys

The following API keys are **NOT** stored in version control:

1. **Google Maps API Key** - Used for map features
2. **Supabase URL & Anon Key** - Backend database access
3. **Firebase Configuration** - Authentication and storage
4. **YouTube API Key** - Video content integration

## How API Keys Are Protected

### 1. Environment Variables (.env)
All API keys are stored in `.env` file:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
GOOGLE_MAPS_API_KEY=your_maps_key
YOUTUBE_API_KEY=your_youtube_key
```

**Status**: ✅ `.env` is in `.gitignore` - NEVER committed to git

### 2. Firebase Configuration
Firebase keys are in `google-services.json` and `firebase_options.dart`:

**Status**: ✅ Both files in `.gitignore` - only `.example` files are tracked

### 3. Google Maps API Key (Android)
The Google Maps API key is injected at build time from `local.properties`:

**android/local.properties**:
```properties
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

**android/app/build.gradle.kts**:
```kotlin
// Load from local.properties (not tracked in git)
val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val googleMapsApiKey: String = localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""

defaultConfig {
    // Inject into AndroidManifest.xml
    manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
}
```

**android/app/src/main/AndroidManifest.xml**:
```xml
<!-- Uses variable placeholder, not hardcoded key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

**Status**: ✅ `local.properties` is in `.gitignore` - NEVER committed

## Git History Check

✅ **No API keys found in git history**
- Verified with: `git log --all --full-history -p -S "AIzaSy"`
- Result: No commits contain the actual Google Maps API key
- The hardcoded key never made it to any commit

## Files Protected by .gitignore

```gitignore
# API Keys and Secrets
.env
android/local.properties
lib/firebase_options.dart
android/app/google-services.json

# Only template/example files are tracked
!.env.example
!android/app/google-services.json.example
!lib/firebase_options.dart.example
!android/local.properties.example
```

## Setup Instructions for New Developers

### 1. Copy Template Files
```bash
# Copy environment variables
cp .env.example .env

# Copy Firebase configuration
cp android/app/google-services.json.example android/app/google-services.json
cp lib/firebase_options.dart.example lib/firebase_options.dart

# Copy local.properties
cp android/local.properties.example android/local.properties
```

### 2. Fill in Actual API Keys
Edit each file and replace placeholder values with your actual API keys:

- `.env` - Add Supabase, YouTube, Google Maps keys
- `google-services.json` - Add your Firebase project configuration
- `firebase_options.dart` - Add your Firebase options
- `android/local.properties` - Add your Google Maps API key

### 3. Verify Security
```bash
# These commands should return NOTHING (files not tracked):
git ls-files | grep "\.env$"
git ls-files | grep "local.properties$"
git ls-files | grep "firebase_options.dart$"
git ls-files | grep "google-services.json$"

# These should show the template files:
git ls-files | grep ".example"
```

## API Key Regeneration (If Exposed)

If an API key was accidentally exposed:

### Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/google/maps-apis)
2. Navigate to "Credentials"
3. Delete the old API key
4. Create a new API key
5. Add restrictions (Android apps, HTTP referrers)
6. Update `.env` and `android/local.properties` with new key

### Supabase Keys
1. Go to Supabase Dashboard → Settings → API
2. Click "Reset" next to anon/public key
3. Update `.env` with new keys
4. Redeploy any apps using the old key

### Firebase Configuration
1. Go to Firebase Console → Project Settings
2. Delete the old Android/iOS app
3. Re-add the app to generate new `google-services.json`
4. Update your local files

## Security Best Practices

✅ **DO**:
- Store all API keys in `.env` or `local.properties`
- Use template files (`.example`) for version control
- Add restrictions to API keys (domain/app restrictions)
- Rotate keys if they're exposed
- Review `.gitignore` before committing

❌ **DON'T**:
- Hardcode API keys directly in source code
- Commit `.env`, `local.properties`, or `google-services.json`
- Share API keys in chat, email, or documentation
- Use production keys in development
- Push sensitive files to public repositories

## Verification Checklist

Before committing code:
- [ ] Run `git status` - verify no sensitive files appear
- [ ] Check `git diff` - ensure no API keys in changes
- [ ] Confirm `.gitignore` includes all sensitive files
- [ ] Test app builds with injected API keys (not hardcoded)
- [ ] Review AndroidManifest.xml uses `${VARIABLE}` not actual keys

## Emergency Response

If you accidentally commit an API key:

1. **Immediately** regenerate the exposed API key
2. Remove from git history:
   ```bash
   # Use BFG Repo-Cleaner or git-filter-repo
   git filter-repo --path android/app/src/main/AndroidManifest.xml --invert-paths
   ```
3. Force push (if repository is private and you're the only dev):
   ```bash
   git push --force
   ```
4. Notify all team members to re-clone the repository

## Contact

For security concerns, contact the project maintainers immediately.

---

**Last Updated**: November 7, 2025  
**Status**: All API keys secured ✅
