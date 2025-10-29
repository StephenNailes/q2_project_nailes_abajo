# EcoSustain Backend Setup Guide

## Firebase & Supabase Integration

This guide will walk you through setting up Firebase and Supabase for your EcoSustain mobile app.

---

## Part 1: Firebase Setup

### Step 1: Create Firebase Project

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Click "Add project"**
3. **Enter project name**: `ecosustain` (or your preferred name)
4. **Disable Google Analytics** (optional, can enable later)
5. **Click "Create project"**

### Step 2: Configure Firebase for Flutter

Run this command in your terminal (make sure you're logged in to Firebase):

```powershell
flutterfire configure
```

This will:
- List your Firebase projects
- Let you select the `ecosustain` project
- Ask which platforms to configure (select: Android, iOS, Web)
- Generate `lib/firebase_options.dart` file automatically
- Update Android and iOS configuration files

**Note**: If the command is not found, add to your PATH:
```
C:\Users\MYPC\AppData\Local\Pub\Cache\bin
```

### Step 3: Enable Firebase Services in Console

#### 3.1 Enable Authentication

1. In Firebase Console, go to **Build > Authentication**
2. Click **Get Started**
3. Click **Sign-in method** tab
4. Enable **Email/Password**:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"
5. Enable **Google Sign-In**:
   - Click on "Google"
   - Toggle "Enable"
   - Enter support email
   - Click "Save"

#### 3.2 Create Firestore Database

1. Go to **Build > Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (we'll add security rules later)
4. Choose location: **us-central** (or closest to you)
5. Click **Enable**

#### 3.3 Set Up Firestore Collections

Create these collections manually or they'll be auto-created by the app:

- `users` - User profiles
- `submissions` - E-waste submissions
- `recycling_history` - Recycling activity log
- `eco_tips` - Eco tips content

#### 3.4 Enable Firebase Storage

1. Go to **Build > Storage**
2. Click **Get started**
3. Select **Start in test mode**
4. Click **Done**

This will store device photos from submissions.

### Step 4: Update Firestore Security Rules

Go to **Firestore Database > Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own submissions
    match /submissions/{submissionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Users can read/write their own history
    match /recycling_history/{historyId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Everyone can read eco tips
    match /eco_tips/{tipId} {
      allow read: if true;
      allow write: if false; // Only admins via Firebase Console
    }
  }
}
```

Click **Publish**.

### Step 5: Update Storage Security Rules

Go to **Storage > Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /submissions/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Click **Publish**.

---

## Part 2: Supabase Setup

### Step 1: Create Supabase Project

1. **Go to Supabase**: https://supabase.com/
2. **Sign up** with GitHub/Google
3. **Click "New project"**
4. **Select organization** (create one if needed)
5. **Enter details**:
   - Name: `ecosustain`
   - Database Password: Choose a strong password (save it!)
   - Region: Choose closest to you
   - Pricing Plan: **Free**
6. **Click "Create new project"** (takes ~2 minutes)

### Step 2: Get Your Supabase Credentials

1. Go to **Project Settings** (gear icon)
2. Go to **API** section
3. Copy these values (you'll need them):
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Anon/Public Key**: `eyJhbGc...` (long key)

### Step 3: Create Database Tables

1. Go to **SQL Editor**
2. Click **New query**
3. Paste this SQL:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  profile_image_url TEXT,
  total_recycled INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Submissions table
CREATE TABLE public.submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL CHECK (item_type IN ('phone', 'laptop', 'charger', 'tablet', 'other')),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  drop_off_location TEXT NOT NULL,
  photo_urls TEXT[],
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Recycling history table
CREATE TABLE public.recycling_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  submission_id UUID REFERENCES public.submissions(id) ON DELETE SET NULL,
  item_type TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  earned_points INTEGER DEFAULT 0,
  recycled_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Eco tips table
CREATE TABLE public.eco_tips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX idx_submissions_status ON public.submissions(status);
CREATE INDEX idx_history_user_id ON public.recycling_history(user_id);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);

-- Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recycling_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.eco_tips ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view all profiles"
  ON public.user_profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Submissions policies
CREATE POLICY "Users can view own submissions"
  ON public.submissions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own submissions"
  ON public.submissions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own submissions"
  ON public.submissions FOR UPDATE
  USING (auth.uid() = user_id);

-- Recycling history policies
CREATE POLICY "Users can view own history"
  ON public.recycling_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own history"
  ON public.recycling_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Eco tips policies (public read)
CREATE POLICY "Anyone can view eco tips"
  ON public.eco_tips FOR SELECT
  USING (true);
```

4. Click **Run** (bottom right)

### Step 4: Enable Authentication

1. Go to **Authentication** in sidebar
2. **Email Auth is enabled by default**
3. For Google Sign-In:
   - Go to **Providers**
   - Click **Google**
   - Enable it
   - Add OAuth credentials from Google Cloud Console

### Step 5: Configure Storage (Optional)

1. Go to **Storage**
2. Create a bucket: `submission-photos`
3. Set policies for user uploads

---

## Part 3: Update Your Flutter App

### Step 1: Add Environment Variables

Create `lib/config/env_config.dart`:

```dart
class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  
  // Use Firebase for primary features
  static const bool useFirebase = true;
  
  // Use Supabase as backup/alternative
  static const bool useSupabase = false;
}
```

**IMPORTANT**: Replace the placeholder values with your actual Supabase credentials!

### Step 2: Run FlutterFire Configure

```powershell
flutterfire configure
```

This creates `lib/firebase_options.dart` automatically.

### Step 3: Initialize in main.dart

The app will initialize both services on startup.

---

## Part 4: Testing Your Setup

### Test Firebase

1. Run the app
2. Try to register a new user
3. Check Firebase Console > Authentication > Users
4. Should see the new user

### Test Firestore

1. Submit a recycling request in the app
2. Check Firebase Console > Firestore Database
3. Should see a new document in `submissions` collection

### Test Supabase (if enabled)

1. Set `useSupabase = true` in `env_config.dart`
2. Run the app and register
3. Check Supabase Dashboard > Table Editor > user_profiles
4. Should see the new user

---

## Common Issues & Solutions

### Issue: "FlutterFire command not found"
**Solution**: Add to PATH: `C:\Users\MYPC\AppData\Local\Pub\Cache\bin`

### Issue: "Firebase not initialized"
**Solution**: Ensure `firebase_options.dart` exists and `Firebase.initializeApp()` is called

### Issue: "Supabase connection failed"
**Solution**: Check your URL and anon key in `env_config.dart`

### Issue: "Permission denied" on Firestore
**Solution**: Update security rules (see Step 4 above)

### Issue: "Google Sign-In not working"
**Solution**: 
- Ensure SHA-1 fingerprint is added in Firebase Console
- Run: `cd android && ./gradlew signingReport`

---

## Next Steps

1. ✅ Complete Firebase setup
2. ✅ Complete Supabase setup  
3. ✅ Test authentication
4. ✅ Test data submission
5. 🔄 Add error handling
6. 🔄 Implement offline mode
7. 🔄 Add push notifications (Firebase Cloud Messaging)

---

## Useful Commands

```powershell
# Get dependencies
flutter pub get

# Run the app
flutter run

# Generate SHA-1 for Google Sign-In
cd android
./gradlew signingReport

# Clean build
flutter clean
flutter pub get
```

---

## Support Resources

- **Firebase Docs**: https://firebase.google.com/docs/flutter/setup
- **Supabase Docs**: https://supabase.com/docs/guides/getting-started/quickstarts/flutter
- **Flutter Docs**: https://docs.flutter.dev/

---

**Good luck with your EcoSustain app! 🌱♻️**
