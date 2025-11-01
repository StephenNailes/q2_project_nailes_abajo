import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for EcoSustain app
/// 
/// This file loads configuration from .env file to keep secrets secure.
/// The .env file is excluded from git for security.
class EnvConfig {
  // ============================================
  // SUPABASE CONFIGURATION
  // ============================================
  
  /// Your Supabase project URL
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  
  /// Your Supabase anon/public key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // ============================================
  // FIREBASE CONFIGURATION
  // ============================================
  
  // Web
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  static String get firebaseWebAppId => dotenv.env['FIREBASE_WEB_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseWebMeasurementId => dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'] ?? '';
  
  // Android
  static String get firebaseAndroidApiKey => dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
  static String get firebaseAndroidAppId => dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';
  
  // Windows
  static String get firebaseWindowsApiKey => dotenv.env['FIREBASE_WINDOWS_API_KEY'] ?? '';
  static String get firebaseWindowsAppId => dotenv.env['FIREBASE_WINDOWS_APP_ID'] ?? '';
  static String get firebaseWindowsMeasurementId => dotenv.env['FIREBASE_WINDOWS_MEASUREMENT_ID'] ?? '';
  
  // ============================================
  // YOUTUBE DATA API
  // ============================================
  
  static String get youtubeApiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  
  // ============================================
  // INITIALIZATION
  // ============================================
  
  /// Initialize environment variables from .env file
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Use debugPrint instead of print for production compatibility
      debugPrint('⚠️ Warning: Could not load .env file: $e');
      debugPrint('Make sure .env file exists in the project root');
    }
  }
  
  // ============================================
  // BACKEND SELECTION
  // ============================================
  // Choose which backend to use for different features
  
  /// Use Firebase as primary backend
  /// Set to true to use Firebase for auth, database, and storage
  static const bool useFirebase = true;
  
  /// Use Supabase as alternative backend
  /// Set to true to use Supabase for auth and database
  /// Note: You can use both simultaneously if needed
  static const bool useSupabase = true;
  
  // ============================================
  // FEATURE FLAGS
  // ============================================
  
  /// Enable Google Sign-In (requires Firebase setup)
  static const bool enableGoogleSignIn = true;
  
  /// Enable offline persistence (Firebase only)
  static const bool enableOfflineMode = true;
  
  /// Enable crash reporting
  static const bool enableCrashReporting = false;
  
  /// Enable analytics
  static const bool enableAnalytics = false;
  
  // ============================================
  // VALIDATION
  // ============================================
  
  /// Check if Supabase is properly configured
  static bool get isSupabaseConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }
  
  /// Get active backend name
  static String get activeBackend {
    if (useFirebase && useSupabase) {
      return 'Firebase + Supabase';
    } else if (useFirebase) {
      return 'Firebase';
    } else if (useSupabase) {
      return 'Supabase';
    }
    return 'None';
  }
}
