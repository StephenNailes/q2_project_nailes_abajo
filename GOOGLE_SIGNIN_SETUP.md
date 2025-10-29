# 🔐 Google Sign-In Setup Guide

## ✅ What's Already Done

Your app **already has Google Sign-In implemented**! The code is ready in:
- ✅ `lib/services/firebase_auth_service.dart` - Full Google Sign-In logic
- ✅ `lib/auth/login_screen.dart` - "Sign in with Google" button
- ✅ `lib/auth/register_screen.dart` - "Sign up with Google" button
- ✅ `pubspec.yaml` - `google_sign_in: ^6.2.2` package installed

## 🚀 How to Enable Google Sign-In

You just need to enable it in Firebase Console. Here's how:

---

## Step 1: Enable Google Sign-In in Firebase Console

### 1.1 Go to Firebase Authentication
Visit: https://console.firebase.google.com/project/eco-sustain-51b9b/authentication/providers

### 1.2 Enable Google Provider
1. Click on **"Google"** in the Sign-in providers list
2. Click the **"Enable"** toggle switch
3. **Project support email**: Select your email from dropdown
4. Click **"Save"**

That's it for web! ✅

---

## Step 2: Platform-Specific Configuration

### For Web (Chrome) ✅
**Already configured!** Your Firebase project is set up for web. No additional steps needed.

### For Android (Future deployment) 📱
When you deploy to Android, you'll need to add SHA-1 fingerprint:

#### Get SHA-1 Fingerprint:
```bash
# Debug SHA-1
cd android
./gradlew signingReport
```

#### Add SHA-1 to Firebase:
1. Go to: https://console.firebase.google.com/project/eco-sustain-51b9b/settings/general
2. Scroll to "Your apps" → Android app
3. Click "Add fingerprint"
4. Paste SHA-1 fingerprint
5. Download new `google-services.json`
6. Replace `android/app/google-services.json`

---

## Step 3: Test Google Sign-In

### Run the App:
```bash
flutter run -d chrome --web-port=8080
```

### Test Flow:
1. Navigate to: `http://localhost:8080/#/login`
2. Click **"Sign in with Google"** button
3. Google account picker should appear
4. Select your Google account
5. You should be signed in and redirected to `/home`

### What Happens Behind the Scenes:
```
1. User clicks Google button
2. Google Sign-In popup opens
3. User selects account
4. Google returns auth token
5. Firebase creates/signs in user
6. If new user → Create Firestore profile
7. Navigate to /home
```

---

## 🎯 How It Works in Your Code

### Login Screen (`lib/auth/login_screen.dart`):
```dart
// When user clicks "Sign in with Google" button
Future<void> _handleGoogleSignIn() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await _authService.signInWithGoogle();
    
    if (mounted) {
      context.go('/home');
    }
  } catch (e) {
    setState(() {
      _errorMessage = _getErrorMessage(e.toString());
      _isLoading = false;
    });
  }
}
```

### Register Screen (`lib/auth/register_screen.dart`):
```dart
// When user clicks "Sign up with Google" button
Future<void> _handleGoogleSignUp() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await _authService.signInWithGoogle();
    
    if (mounted) {
      context.go('/home');
    }
  } catch (e) {
    setState(() {
      _errorMessage = _getErrorMessage(e.toString());
      _isLoading = false;
    });
  }
}
```

### Firebase Auth Service (`lib/services/firebase_auth_service.dart`):
```dart
Future<UserCredential?> signInWithGoogle() async {
  try {
    // 1. Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null; // User cancelled
    }

    // 2. Get authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to Firebase
    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // 5. Create Firestore profile for new users
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      await _createUserProfile(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName ?? 'User',
        profileImageUrl: userCredential.user!.photoURL,
      );
    }

    return userCredential;
  } catch (e) {
    throw Exception('Failed to sign in with Google: $e');
  }
}
```

---

## 🔍 What User Data is Collected

When a user signs in with Google, Firebase gets:
- ✅ **User ID** (Firebase UID)
- ✅ **Email** (Google account email)
- ✅ **Display Name** (Google account name)
- ✅ **Profile Photo URL** (Google profile picture)

This data is automatically saved to Firestore in `users/{userId}`:
```json
{
  "id": "firebase-uid-here",
  "name": "John Doe",
  "email": "john@gmail.com",
  "profileImageUrl": "https://lh3.googleusercontent.com/...",
  "totalRecycled": 0,
  "createdAt": "2025-10-30T..."
}
```

---

## 🎨 UI/UX Features

### Google Sign-In Button:
- ✅ Google "G" logo from assets
- ✅ "Sign in with Google" / "Sign up with Google" text
- ✅ White background with gray border
- ✅ Disabled during loading
- ✅ Shows loading spinner on click

### Error Handling:
- ✅ User cancels → No error shown
- ✅ Network error → "Network error. Check your connection"
- ✅ Account disabled → "This account has been disabled"
- ✅ Too many requests → "Too many attempts. Please try again later"

### Success Flow:
- ✅ Instant navigation to `/home`
- ✅ User profile auto-created (if new user)
- ✅ User session persisted (stays logged in)

---

## 🧪 Testing Checklist

### Before Testing:
- [ ] Google Sign-In enabled in Firebase Console
- [ ] Support email configured
- [ ] App running on `http://localhost:8080`

### Test Cases:
- [ ] Click "Sign in with Google" on login screen
- [ ] Google account picker appears
- [ ] Select account → Sign in successful
- [ ] Redirected to `/home`
- [ ] Sign out and try again (existing user flow)
- [ ] Click "Sign up with Google" on register screen
- [ ] Same flow works from register screen
- [ ] Cancel Google sign-in → No error, stays on screen
- [ ] Try with account that has no display name
- [ ] Check Firestore for created user profile

### Verify in Firebase Console:
1. Go to: https://console.firebase.google.com/project/eco-sustain-51b9b/authentication/users
2. You should see your Google account listed
3. Go to: https://console.firebase.google.com/project/eco-sustain-51b9b/firestore
4. Check `users/{userId}` document exists

---

## 🐛 Troubleshooting

### Issue: "popup_closed_by_user" error
**Solution:** User cancelled sign-in. This is expected behavior.

### Issue: "network-request-failed"
**Solution:** Check internet connection, Firebase project is online.

### Issue: Google popup doesn't appear
**Solution:** 
- Clear browser cache
- Disable popup blockers
- Check browser console for errors

### Issue: "auth/popup-blocked"
**Solution:** Allow popups for `localhost:8080` in browser settings.

### Issue: User signed in but not redirected
**Solution:** Check router configuration in `lib/routes/app_router.dart`.

### Issue: Firestore profile not created
**Solution:** 
- Check Firestore rules allow writes
- Check `_createUserProfile()` method in auth service
- Verify Firebase initialization in `main.dart`

### Issue: Google button disabled
**Solution:** Check `_isLoading` state, might be stuck in loading.

---

## 📋 Quick Start Commands

```bash
# 1. Make sure dependencies are installed
flutter pub get

# 2. Run the app
flutter run -d chrome --web-port=8080

# 3. Open browser
# Navigate to: http://localhost:8080/#/login

# 4. Click "Sign in with Google"

# 5. Check Firebase Console for user
# https://console.firebase.google.com/project/eco-sustain-51b9b/authentication/users
```

---

## 🔒 Security Notes

### OAuth Scopes:
Google Sign-In requests these scopes by default:
- `email` - User's email address
- `profile` - User's basic profile info

### Privacy:
- ✅ No password stored (handled by Google)
- ✅ Only public profile data accessed
- ✅ User can revoke access anytime in Google Account settings
- ✅ Firebase handles all OAuth token management

### Firestore Rules:
Ensure your Firestore rules allow profile creation:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow users to read/write their own profile
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🎉 That's It!

Google Sign-In is **fully implemented and ready to use**! 

Just enable it in Firebase Console and test:
1. Go to: https://console.firebase.google.com/project/eco-sustain-51b9b/authentication/providers
2. Enable Google
3. Add support email
4. Save
5. Run `flutter run -d chrome --web-port=8080`
6. Click "Sign in with Google" button
7. Done! ✅

---

## 📚 Additional Resources

- [Firebase Google Sign-In Docs](https://firebase.google.com/docs/auth/web/google-signin)
- [Google Sign-In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication Best Practices](https://firebase.google.com/docs/auth/best-practices)

---

**Need help?** Check the error messages in the browser console or Firebase Console logs.
