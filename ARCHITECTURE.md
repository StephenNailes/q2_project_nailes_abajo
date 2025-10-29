# EcoSustain App Architecture

## 📊 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        EcoSustain Flutter App                    │
│                    (Android/iOS Mobile App)                      │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  │
                    ┌─────────────┴──────────────┐
                    │                            │
                    ▼                            ▼
         ┌──────────────────┐         ┌──────────────────┐
         │  Firebase (🔥)   │         │ Supabase (🐘)    │
         │                  │         │                  │
         │  • Authentication│         │ • Authentication │
         │  • Firestore DB  │         │ • PostgreSQL DB  │
         │  • Storage       │         │ • Storage        │
         │  • Analytics     │         │ • Real-time      │
         └──────────────────┘         └──────────────────┘
```

---

## 🏗️ Application Layer Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                           UI Layer                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Login   │  │Dashboard │  │Submission│  │ Profile  │       │
│  │  Screen  │  │  Screen  │  │  Wizard  │  │  Screen  │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Service Layer                              │
│  ┌────────────────────┐  ┌────────────────────┐                │
│  │ FirebaseAuthService│  │SupabaseService     │                │
│  │ • registerWithEmail│  │ • registerWithEmail│                │
│  │ • loginWithEmail   │  │ • loginWithEmail   │                │
│  │ • signInWithGoogle │  │ • getUserProfile   │                │
│  │ • getUserProfile   │  │ • createSubmission │                │
│  └────────────────────┘  └────────────────────┘                │
│                                                                  │
│  ┌────────────────────────────┐                                │
│  │ FirebaseSubmissionService  │                                │
│  │ • createSubmission         │                                │
│  │ • getUserSubmissions       │                                │
│  │ • uploadPhotos             │                                │
│  └────────────────────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Models                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │UserModel │  │Submission│  │Recycling │  │ EcoTip   │       │
│  │          │  │  Model   │  │ History  │  │  Model   │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 User Authentication Flow

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. Enters email & password
     ▼
┌─────────────────┐
│  Login Screen   │
└────┬────────────┘
     │
     │ 2. Calls FirebaseAuthService.loginWithEmail()
     ▼
┌──────────────────────┐
│ FirebaseAuthService  │
└────┬─────────────────┘
     │
     │ 3. Authenticates with Firebase
     ▼
┌──────────────────┐
│  Firebase Auth   │
└────┬─────────────┘
     │
     │ 4. Returns User object
     ▼
┌──────────────────┐
│  User logged in  │
│  Navigate /home  │
└──────────────────┘
```

---

## 📤 Submission Creation Flow

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. Goes through 5-step wizard
     │    Step 1: Select item type
     │    Step 2: Choose quantity
     │    Step 3: Pick drop-off location
     │    Step 4: Take photos
     │    Step 5: Review & submit
     ▼
┌──────────────────────┐
│  Step5Submit Screen  │
└────┬─────────────────┘
     │
     │ 2. Calls FirebaseSubmissionService.createSubmission()
     ▼
┌─────────────────────────────┐
│ FirebaseSubmissionService   │
└────┬────────────────────────┘
     │
     │ 3. Upload photos to Storage
     ▼
┌──────────────────┐
│Firebase Storage  │
└────┬─────────────┘
     │
     │ 4. Returns photo URLs
     ▼
┌─────────────────────────────┐
│ FirebaseSubmissionService   │
└────┬────────────────────────┘
     │
     │ 5. Save submission data to Firestore
     ▼
┌──────────────────┐
│   Firestore DB   │
│   submissions/   │
│   └─ {docId}     │
│      ├─ userId   │
│      ├─ itemType │
│      ├─ quantity │
│      └─ photoUrls│
└──────────────────┘
```

---

## 📊 Database Schema

### Firebase Firestore Collections

```
firestore/
├── users/
│   └── {userId}
│       ├── name: string
│       ├── email: string
│       ├── profileImageUrl: string
│       ├── totalRecycled: number
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── submissions/
│   └── {submissionId}
│       ├── userId: string
│       ├── itemType: string (phone|laptop|charger|tablet|other)
│       ├── quantity: number
│       ├── dropOffLocation: string
│       ├── photoUrls: array<string>
│       ├── status: string (pending|processing|completed|cancelled)
│       ├── createdAt: timestamp
│       └── completedAt: timestamp?
│
├── recycling_history/
│   └── {historyId}
│       ├── userId: string
│       ├── submissionId: string?
│       ├── itemType: string
│       ├── quantity: number
│       ├── earnedPoints: number
│       └── recycledDate: timestamp
│
└── eco_tips/
    └── {tipId}
        ├── title: string
        ├── description: string
        ├── category: string
        ├── imageUrl: string?
        └── createdAt: timestamp
```

### Supabase PostgreSQL Tables

```sql
-- Similar structure but with PostgreSQL types
-- user_profiles (extends auth.users)
-- submissions
-- recycling_history  
-- eco_tips
```

---

## 🔐 Security Rules

### Firestore Security Rules

```javascript
// Users can read/write their own data
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
}

// Users can read/write their own submissions
match /submissions/{submissionId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update, delete: if resource.data.userId == request.auth.uid;
}
```

---

## 📂 Project File Structure

```
lib/
├── main.dart                    # App entry point, initializes backends
├── config/
│   └── env_config.dart         # Backend configuration
├── models/
│   ├── user_model.dart         # User data model
│   ├── submission_model.dart   # Submission model
│   ├── recycling_history_model.dart
│   └── eco_tip_model.dart
├── services/
│   ├── firebase_auth_service.dart        # Firebase authentication
│   ├── firebase_submission_service.dart  # Firebase submissions
│   └── supabase_service.dart            # Supabase all-in-one
├── auth/
│   ├── login_screen.dart       # Login UI
│   └── register_screen.dart    # Registration UI
├── screen/
│   ├── dashboard_screen.dart
│   ├── profile_screen.dart
│   └── submission_screen.dart
├── components/
│   ├── submission/
│   │   ├── step1_select.dart   # Item selection
│   │   ├── step2_quantity.dart # Quantity picker
│   │   ├── step3_dropoff.dart  # Location picker
│   │   ├── step4_photo.dart    # Photo capture
│   │   └── step5_submit.dart   # Final submission
│   └── eco_bottom_nav.dart     # Bottom navigation
└── routes/
    └── app_router.dart         # Route configuration
```

---

## 🔄 Data Flow Example: User Registration

```
User fills form
    ↓
RegisterScreen validates input
    ↓
Calls FirebaseAuthService.registerWithEmail(email, password, name)
    ↓
Firebase creates user account
    ↓
FirebaseAuthService creates user profile in Firestore
    ↓
User logged in automatically
    ↓
Navigate to /home (Dashboard)
    ↓
Dashboard loads user data from Firestore
    ↓
Display personalized dashboard
```

---

## 🎯 Integration Points (What You Need to Do)

### Already Done ✅
- [x] Dependencies installed
- [x] Models created
- [x] Services created  
- [x] Main.dart initialized
- [x] Documentation written

### TODO - Your Next Steps 🔧
- [ ] Run `flutterfire configure`
- [ ] Enable Firebase services in console
- [ ] Update auth screens to use Firebase
- [ ] Update submission wizard to save to Firebase
- [ ] Test authentication flow
- [ ] Test submission flow

---

## 💡 How to Use the Services

### Example: Login User

```dart
import 'services/firebase_auth_service.dart';

final authService = FirebaseAuthService();

try {
  await authService.loginWithEmail(
    email: 'user@example.com',
    password: 'password123',
  );
  // Navigate to home
  context.go('/home');
} catch (e) {
  // Show error
  print('Login failed: $e');
}
```

### Example: Create Submission

```dart
import 'services/firebase_submission_service.dart';

final submissionService = FirebaseSubmissionService();

try {
  final submissionId = await submissionService.createSubmission(
    userId: authService.currentUserId!,
    itemType: 'phone',
    quantity: 2,
    dropOffLocation: 'Downtown Recycling Center',
    photoFiles: [imageFile1, imageFile2],
  );
  print('Submission created: $submissionId');
} catch (e) {
  print('Submission failed: $e');
}
```

---

**This architecture provides a clean separation of concerns and makes it easy to switch between Firebase and Supabase!**
