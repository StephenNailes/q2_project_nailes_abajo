/// Environment configuration for EcoSustain app
/// 
/// This file contains configuration for Firebase and Supabase.
/// Follow the SETUP_GUIDE.md to get your credentials.
class EnvConfig {
  // ============================================
  // SUPABASE CONFIGURATION
  // ============================================
  // Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
  
  /// Your Supabase project URL
  /// Example: 'https://xxxxxxxxxxxxx.supabase.co'
  static const String supabaseUrl = 'https://uxiticipaqsfpsvijbcn.supabase.co';
  
  /// Your Supabase anon/public key
  /// Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV4aXRpY2lwYXFzZnBzdmlqYmNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NjcyMzcsImV4cCI6MjA3NzM0MzIzN30.2393xhFT3p41liNjiVjVwD53CjmmsPLq9s-ljg1eygA';
  
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
