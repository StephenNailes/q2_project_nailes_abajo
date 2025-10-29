# 📱 Android Google Sign-In Setup - COMPLETE GUIDE

## ✅ Your SHA-1 Fingerprint (Already Retrieved)

```
SHA-1: 92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0
```

---

## 🚀 Step-by-Step Setup

### Step 1: Add SHA-1 to Firebase Console

1. **Go to Firebase Project Settings:**
   https://console.firebase.google.com/project/eco-sustain-51b9b/settings/general

2. **Scroll down to "Your apps" section**

3. **Find your Android app:** `eco_sustain (android)` 
   - Package name: `com.example.eco_sustain`

4. **Click "Add fingerprint"** button

5. **Paste the SHA-1 fingerprint:**
   ```
   92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0
   ```

6. **Click "Save"**

---

### Step 2: Download New google-services.json

After adding the SHA-1, Firebase will generate a new configuration file.

1. **You'll see a notification** saying "Download latest configuration file"

2. **Click "Download google-services.json"**

3. **Replace the old file:**
   - Delete: `android/app/google-services.json`
   - Copy the downloaded file to: `android/app/google-services.json`

**OR use this PowerShell command:**
```powershell
Copy-Item -Path "C:\Users\MYPC\Downloads\google-services.json" -Destination "android\app\google-services.json" -Force
```

---

### Step 3: Run the App on Android Emulator

```bash
# Start Android emulator first (or connect real device)
# Then run:
flutter run
```

**OR for specific device:**
```bash
flutter devices
flutter run -d <device-id>
```

---

## 🧪 Testing Google Sign-In on Android

1. **Launch the app on emulator**
2. **Navigate to login screen**
3. **Click "Sign in with Google"**
4. **Google account picker should appear**
5. **Select your account**
6. **Sign in successful!** ✅

---

## ⚠️ Important Notes

### For Android Emulator:
- ✅ Emulator must have Google Play Services installed
- ✅ Sign in with a Google account in the emulator first (Settings → Accounts)
- ✅ SHA-1 must be added to Firebase Console

### Debug vs Release:
- **Debug SHA-1** (what we got): Used for development/testing
- **Release SHA-1**: Needed when publishing to Play Store
  ```bash
  # Get release SHA-1 later when you create release keystore
  keytool -list -v -keystore path/to/release.keystore
  ```

---

## 🔧 Troubleshooting

### Issue: "Developer Error" or "10" error
**Solution:** SHA-1 not added or wrong google-services.json
- Verify SHA-1 in Firebase Console
- Download and replace google-services.json
- Clean build: `flutter clean && flutter pub get`

### Issue: "Sign in failed"
**Solution:** 
- Check internet connection
- Ensure Google Sign-In enabled in Firebase Console
- Verify google-services.json is correct version (after adding SHA-1)

### Issue: "Google Play Services not available"
**Solution:**
- Use emulator with Google Play (not Google APIs)
- Or use a real Android device

### Issue: Account picker doesn't appear
**Solution:**
- Sign in to a Google account on the emulator first
- Go to Settings → Accounts → Add Google Account

---

## 📋 Quick Checklist

Before testing on Android:
- [ ] SHA-1 added to Firebase Console (`92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0`)
- [ ] New google-services.json downloaded
- [ ] File placed at `android/app/google-services.json`
- [ ] Google Sign-In enabled in Firebase Console
- [ ] Emulator running with Google Play Services
- [ ] Google account signed in on emulator

---

## 🎯 Complete Setup Commands

```bash
# 1. Add SHA-1 to Firebase Console (manual step in browser)

# 2. Download new google-services.json (manual step)

# 3. Replace the file
Copy-Item -Path "C:\Users\MYPC\Downloads\google-services.json" -Destination "android\app\google-services.json" -Force

# 4. Clean and rebuild
flutter clean
flutter pub get

# 5. Run on Android
flutter run
```

---

## ✅ What's Already Done

- ✅ SHA-1 fingerprint retrieved: `92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0`
- ✅ Google Sign-In code implemented in app
- ✅ Firebase Auth Service ready
- ✅ UI buttons for Google Sign-In
- ✅ Web Client ID configured in `web/index.html`

---

## 🎉 Next Steps

1. **Add SHA-1 to Firebase** (2 minutes)
   - Go to: https://console.firebase.google.com/project/eco-sustain-51b9b/settings/general
   - Add fingerprint: `92:98:BD:B3:AC:EE:A1:4A:71:2C:69:9C:4D:B8:8B:80:81:7C:EF:C0`

2. **Download google-services.json** (30 seconds)
   - Click download button
   - Replace file in `android/app/`

3. **Test it!** (5 minutes)
   ```bash
   flutter run
   ```

---

## 📱 Expected Behavior

**On Android Emulator:**
1. Tap "Sign in with Google" button
2. See Google account picker dialog
3. Select account
4. App navigates to home screen
5. User is signed in! ✅

**On Web (Chrome):**
- Already working with web client ID in index.html

---

That's it! Just add the SHA-1 to Firebase Console and download the new google-services.json! 🚀
