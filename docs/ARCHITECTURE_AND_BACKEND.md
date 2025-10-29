# 🏗️ EcoSustain - Architecture & Backend Integration

> **Complete guide to the app's architecture, backend services, and data flow**

---

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Backend Stack](#backend-stack)
3. [Data Models](#data-models)
4. [Service Layer](#service-layer)
5. [Authentication Flow](#authentication-flow)
6. [Data Flow](#data-flow)

---

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Dart)                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │   Screens  │  │ Components │  │   Routes   │        │
│  └─────┬──────┘  └──────┬─────┘  └──────┬─────┘        │
│        │                │                │              │
│        └────────────────┴────────────────┘              │
│                         │                               │
│                ┌────────▼────────┐                      │
│                │  Service Layer  │                      │
│                └────────┬────────┘                      │
│                         │                               │
│        ┌────────────────┼────────────────┐             │
│        │                │                │             │
│   ┌────▼────┐    ┌─────▼─────┐   ┌─────▼─────┐       │
│   │Firebase │    │  Supabase │   │  Storage  │       │
│   │  Auth   │    │ PostgreSQL│   │ (Firebase)│       │
│   └─────────┘    └───────────┘   └───────────┘       │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## Backend Stack

### Dual Backend Architecture

**Why Both Firebase and Supabase?**

```
┌─────────────────────────────────────────────┐
│         EcoSustain Backend Stack            │
├─────────────────────────────────────────────┤
│  🔐 Authentication: Firebase Auth           │
│     - Email/Password login                  │
│     - Google Sign-In                        │
│     - Session management                    │
│                                             │
│  🗄️  Database: Supabase PostgreSQL          │
│     - User profiles                         │
│     - Submissions                           │
│     - Recycling history                     │
│     - Eco tips                              │
│                                             │
│  📸 Storage: Firebase Storage               │
│     - Profile pictures                      │
│     - Submission photos                     │
└─────────────────────────────────────────────┘
```

### Why Firebase Auth?
- ✅ Industry-leading security
- ✅ Easy Google Sign-In integration
- ✅ Built-in email verification
- ✅ Password reset flows
- ✅ Session management
- ✅ Free unlimited users

### Why Supabase Database?
- ✅ Full PostgreSQL power
- ✅ Real-time subscriptions
- ✅ Row-level security (RLS)
- ✅ Automatic REST API
- ✅ Better for relational data
- ✅ Easy SQL queries

### Why Firebase Storage?
- ✅ Optimized for mobile
- ✅ Automatic image optimization
- ✅ CDN distribution
- ✅ Easy integration with Firebase Auth

---

## Data Models

### 1. UserModel (`lib/models/user_model.dart`)

```dart
class UserModel {
  final String id;              // Firebase Auth UID
  final String name;            // Full name
  final String email;           // Email address
  final String? profileImageUrl; // Profile picture URL
  final int totalRecycled;      // Total items recycled
  final DateTime createdAt;     // Account creation date
  final DateTime? updatedAt;    // Last update timestamp
}
```

**Storage**: Supabase `user_profiles` table

### 2. SubmissionModel (`lib/models/submission_model.dart`)

```dart
class SubmissionModel {
  final String id;              // Unique submission ID
  final String userId;          // Owner's Firebase Auth UID
  final String itemType;        // phone, laptop, charger, etc.
  final int quantity;           // Number of items
  final String dropOffLocation; // Selected location
  final List<String> photoUrls; // Firebase Storage URLs
  final String status;          // pending, completed
  final DateTime createdAt;     // Submission timestamp
  final DateTime? completedAt;  // Completion timestamp
}
```

**Storage**: Supabase `submissions` table

### 3. RecyclingHistoryModel (`lib/models/recycling_history_model.dart`)

```dart
class RecyclingHistoryModel {
  final String id;              // Unique history ID
  final String userId;          // Owner's Firebase Auth UID
  final String? submissionId;   // Related submission (optional)
  final String itemType;        // Type of item recycled
  final int quantity;           // Number of items
  final int earnedPoints;       // Points earned
  final DateTime recycledDate;  // Date recycled
}
```

**Storage**: Supabase `recycling_history` table

### 4. EcoTipModel (`lib/models/eco_tip_model.dart`)

```dart
class EcoTipModel {
  final String id;              // Unique tip ID
  final String title;           // Tip title
  final String content;         // Tip description
  final String category;        // Category (reduce, reuse, recycle)
  final DateTime createdAt;     // Creation timestamp
}
```

**Storage**: Supabase `eco_tips` table

---

## Service Layer

### 1. FirebaseAuthService (`lib/services/firebase_auth_service.dart`)

**Purpose**: Handle all authentication operations

**Key Methods**:
```dart
// Registration
Future<UserCredential?> registerWithEmail(String email, String password, String name)

// Login
Future<UserCredential?> loginWithEmail(String email, String password)
Future<UserCredential?> signInWithGoogle()

// Password Management
Future<void> sendPasswordResetEmail(String email)
Future<void> changePassword(String currentPassword, String newPassword)

// Email Management
Future<void> updateEmail(String newEmail)
Future<void> verifyBeforeUpdateEmail(String newEmail, String password)

// User Management
Future<void> updateDisplayName(String displayName)
Future<void> signOut()
```

**Authentication Flow**:
```
User Input → FirebaseAuthService → Firebase Auth
                    ↓
              UserCredential
                    ↓
          Create Supabase Profile
                    ↓
            Navigate to Home
```

### 2. SupabaseService (`lib/services/supabase_service.dart`)

**Purpose**: Handle all database operations

**Key Methods**:
```dart
// User Profiles
Future<void> createOrUpdateUserProfile(UserModel userModel)
Future<UserModel?> getUserProfile(String userId)
Future<void> updateUserProfile({String? name, String? profileImageUrl})

// Submissions
Future<String> createSubmission({...})
Future<List<SubmissionModel>> getUserSubmissions(String userId)
Future<void> updateSubmissionStatus(String submissionId, String status)

// Recycling History
Future<void> addRecyclingHistory({...})
Future<List<RecyclingHistoryModel>> getRecyclingHistory(String userId)

// Eco Tips
Future<List<EcoTipModel>> getEcoTips()
Future<List<EcoTipModel>> getEcoTipsByCategory(String category)

// Statistics
Future<int> getTotalItemsRecycled(String userId)
```

**Database Schema**:
```sql
-- User Profiles (text ID for Firebase Auth compatibility)
user_profiles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  profile_image_url TEXT,
  total_recycled INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)

-- Submissions
submissions (
  id UUID PRIMARY KEY,
  user_id TEXT REFERENCES user_profiles(id),
  item_type TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  drop_off_location TEXT NOT NULL,
  photo_urls TEXT[],
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
)

-- Recycling History
recycling_history (
  id UUID PRIMARY KEY,
  user_id TEXT REFERENCES user_profiles(id),
  submission_id UUID REFERENCES submissions(id),
  item_type TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  earned_points INTEGER DEFAULT 0,
  recycled_date TIMESTAMPTZ
)

-- Eco Tips
eco_tips (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ
)
```

### 3. FirebaseStorageService (`lib/services/firebase_storage_service.dart`)

**Purpose**: Handle file uploads to Firebase Storage

**Key Methods**:
```dart
// Profile Pictures
Future<String?> uploadProfilePicture(File imageFile, String userId)
Future<void> deleteProfilePicture(String userId)

// Submission Photos
Future<List<String>> uploadSubmissionPhotos(List<File> images, String userId, String submissionId)
Future<void> deleteSubmissionPhotos(List<String> photoUrls)
```

**Storage Structure**:
```
gs://eco-sustain-51b9b.firebasestorage.app/
├── profile_pictures/
│   └── {userId}/
│       └── profile.jpg
└── submissions/
    └── {userId}/
        └── {submissionId}/
            ├── photo_1.jpg
            ├── photo_2.jpg
            └── photo_3.jpg
```

---

## Authentication Flow

### Email/Password Registration

```
1. User fills registration form
   ↓
2. Validate input (name, email, password, terms)
   ↓
3. FirebaseAuthService.registerWithEmail()
   ↓
4. Firebase creates auth account
   ↓
5. Update Firebase Auth displayName
   ↓
6. Create Supabase user profile
   ↓
7. Navigate to /home
```

### Google Sign-In

```
1. User clicks "Sign in with Google"
   ↓
2. Google account picker appears
   ↓
3. User selects account
   ↓
4. FirebaseAuthService.signInWithGoogle()
   ↓
5. Firebase returns UserCredential
   ↓
6. Create/update Supabase profile
   ↓
7. Navigate to /home
```

### Login Flow

```
1. User enters email/password
   ↓
2. FirebaseAuthService.loginWithEmail()
   ↓
3. Firebase validates credentials
   ↓
4. Return UserCredential
   ↓
5. Navigate to /home
   ↓
6. Load user profile from Supabase
```

---

## Data Flow

### Submission Flow (5-Step Wizard)

```
Step 1: Select Item Type
   ↓
Step 2: Choose Quantity
   ↓
Step 3: Select Drop-Off Location
   ↓
Step 4: Capture Photos
   ↓
Step 5: Review & Submit
   ↓
Upload photos to Firebase Storage
   ↓
Save submission to Supabase
   ↓
Update recycling history
   ↓
Navigate to confirmation screen
```

### Profile Update Flow

```
User edits profile
   ↓
Upload new profile picture (if changed)
   ↓
Get Firebase Storage URL
   ↓
Update Firebase Auth displayName
   ↓
Update Supabase user profile
   ↓
Refresh UI
```

### Dashboard Data Loading

```
User navigates to Dashboard
   ↓
Get current Firebase Auth user
   ↓
Load user profile from Supabase
   ↓
Extract first name for display
   ↓
Display profile image (or default icon)
   ↓
Show total recycled items count
   ↓
Load eco tips from Supabase
```

---

## Security

### Firebase Auth Security
- ✅ Email verification required
- ✅ Password strength validation (min 6 chars)
- ✅ Secure password reset flow
- ✅ Session tokens auto-refreshed
- ✅ Re-authentication for sensitive operations

### Supabase Row Level Security (RLS)

**Current Configuration**: Permissive (Firebase Auth handles security)

```sql
-- Allow all operations (Firebase Auth controls access)
CREATE POLICY "Allow all operations" 
ON user_profiles FOR ALL 
USING (true) WITH CHECK (true);
```

**Why Permissive RLS?**
- Firebase Auth manages authentication
- Flutter app validates user permissions
- Simplified for development
- Can be tightened for production

### Firebase Storage Security

```javascript
// Users can only upload to their own folders
match /profile_pictures/{userId}/{fileName} {
  allow write: if request.auth.uid == userId;
}

match /submissions/{userId}/{submissionId}/{fileName} {
  allow write: if request.auth.uid == userId;
}
```

---

## Performance Optimizations

### Caching Strategy
- User profile cached after first load
- Submissions cached locally
- Images cached by Flutter
- Supabase real-time subscriptions for live updates

### Database Indexes
```sql
CREATE INDEX idx_submissions_user_id ON submissions(user_id);
CREATE INDEX idx_submissions_status ON submissions(status);
CREATE INDEX idx_recycling_history_user_id ON recycling_history(user_id);
CREATE INDEX idx_eco_tips_category ON eco_tips(category);
```

### Image Optimization
- Compress images before upload
- Resize profile pictures to 512x512
- Lazy load images in lists
- Use cached network images

---

## Error Handling

### Firebase Auth Errors
```dart
try {
  await FirebaseAuthService().loginWithEmail(email, password);
} catch (e) {
  if (e.code == 'user-not-found') {
    // Show "No user found" error
  } else if (e.code == 'wrong-password') {
    // Show "Incorrect password" error
  }
}
```

### Supabase Errors
```dart
try {
  await SupabaseService().createSubmission(...);
} catch (e) {
  // Log error and show user-friendly message
  debugPrint('Submission failed: $e');
  showErrorSnackBar('Failed to create submission');
}
```

---

## Testing

### Unit Tests
- Test data model serialization/deserialization
- Test service methods with mocked backends
- Test validation logic

### Integration Tests
- Test complete authentication flows
- Test submission creation end-to-end
- Test profile updates

### Manual Testing Checklist
- [ ] Email/password registration
- [ ] Google Sign-In
- [ ] Password reset
- [ ] Profile picture upload
- [ ] Submission creation
- [ ] Recycling history display
- [ ] Eco tips loading

---

*Last Updated: October 30, 2025*
