# 🌱 EcoSustain (TechSustain)

> **E-waste Recycling Management Mobile App**

A Flutter mobile application for managing electronics recycling submissions. Users can submit e-waste items through a multi-step workflow, track their recycling history, access eco tips, and manage their profile.

---

## 📱 Features

- ✅ **Authentication**: Email/Password + Google Sign-In
- ✅ **Multi-Step Submission**: 5-step wizard for e-waste submissions
- ✅ **Profile Management**: Edit profile, change password, manage email
- ✅ **Photo Uploads**: Capture and upload device photos
- ✅ **Recycling History**: Track all submitted items
- ✅ **Eco Tips**: Environmental tips and guides
- ✅ **Dashboard**: View recycling statistics and recent activity

---

## 🚀 Quick Start

```powershell
# Clone repository
git clone https://github.com/StephenNailes/q2_project_nailes_abajo.git
cd Eco-Sustain-Flutter-App

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📚 Documentation

All documentation has been consolidated into the `docs/` folder:

### 📖 **[Setup & Configuration Guide](docs/SETUP_AND_CONFIGURATION.md)**
Complete guide for Firebase, Supabase, and Google Sign-In setup
- Firebase configuration
- Supabase database setup
- Google Sign-In for Android/Web
- Security rules and configuration

### 🏗️ **[Architecture & Backend Guide](docs/ARCHITECTURE_AND_BACKEND.md)**
System architecture, data models, and backend integration
- System architecture overview
- Data models (User, Submission, History, EcoTip)
- Service layer documentation
- Authentication and data flow
- Security and performance

### 💻 **[Developer Guide](docs/DEVELOPER_GUIDE.md)**
Quick reference for development and common tasks
- Development commands
- Project structure
- Common tasks and patterns
- Troubleshooting
- Code style guide

### 🚀 **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)**
Production deployment to Google Play Store and Web
- Pre-deployment checklist
- Android deployment steps
- Web deployment (Firebase Hosting)
- Post-deployment monitoring

---

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.8.1+
- Dart 3.0+
- Go Router (navigation)
- Material Design

**Backend:**
- Firebase Auth (authentication)
- Supabase PostgreSQL (database)
- Firebase Storage (file uploads)

**Key Packages:**
- `firebase_core: ^3.6.0`
- `firebase_auth: ^5.3.1`
- `firebase_storage: ^12.3.4`
- `supabase_flutter: ^2.8.0`
- `google_sign_in: ^6.2.2`
- `go_router: ^16.2.1`
- `image_picker: ^1.0.7`

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── routes/app_router.dart       # Navigation configuration
├── auth/                        # Login & registration screens
├── screen/                      # Main app screens
├── components/                  # Reusable UI components
├── services/                    # Backend services
├── models/                      # Data models
└── assets/                      # Images and assets
```

---

## 🔐 Configuration

### Firebase Project
- **Project ID**: `eco-sustain-51b9b`
- **Package**: `com.example.eco_sustain`

### Supabase Project
- **Project URL**: `https://uxiticipaqsfpsvijbcn.supabase.co`

See [Setup Guide](docs/SETUP_AND_CONFIGURATION.md) for detailed configuration steps.

---

## 🧪 Testing

```powershell
# Run tests
flutter test

# Analyze code
flutter analyze

# Check setup
flutter doctor -v
```

---

## 📦 Building

```powershell
# Build APK (Android)
flutter build apk --release

# Build AAB (Play Store)
flutter build appbundle --release

# Build Web
flutter build web --release
```

---

## 👥 Contributors

- **Stephen Craine Nailes** - Developer
- **Kert Abajo** - Developer

---

## 📄 License

This project is part of an academic requirement.

---

## 🔗 Resources

- **Firebase Console**: https://console.firebase.google.com/project/eco-sustain-51b9b
- **Supabase Dashboard**: https://supabase.com/dashboard/project/uxiticipaqsfpsvijbcn
- **Flutter Docs**: https://docs.flutter.dev/
- **GitHub Repository**: https://github.com/StephenNailes/q2_project_nailes_abajo

---

*For detailed setup instructions, see the [Setup Guide](docs/SETUP_AND_CONFIGURATION.md)*
