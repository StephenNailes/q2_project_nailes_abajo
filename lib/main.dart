import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_router.dart';
import 'config/env_config.dart';
import 'firebase_options.dart';

/// Main entry point for the EcoSustain app
/// Initializes Firebase and Supabase before running the app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase (if enabled)
    if (EnvConfig.useFirebase) {
      await _initializeFirebase();
    }

    // Initialize Supabase (if enabled and configured)
    if (EnvConfig.useSupabase && EnvConfig.isSupabaseConfigured) {
      await _initializeSupabase();
    }

    // Run the app
    runApp(const EcoSustainApp());
  } catch (e) {
    // If initialization fails, show error screen
    debugPrint('❌ Initialization error: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

/// Initialize Firebase
Future<void> _initializeFirebase() async {
  try {
    // Initialize Firebase with generated configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('💡 Check that Firebase services are enabled in Firebase Console');
    // Don't rethrow - allow app to run without Firebase for now
  }
}

/// Initialize Supabase
Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Supabase initialization failed: $e');
    debugPrint('💡 Update lib/config/env_config.dart with your Supabase credentials');
    // Don't rethrow - allow app to run without Supabase for now
  }
}

class EcoSustainApp extends StatelessWidget {
  const EcoSustainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EcoSustain',
      theme: ThemeData(
        primaryColor: const Color(0xFF2ECC71),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71),
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

/// Error app shown when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFE9FBEF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Run: flutterfire configure\n'
                  '2. Update lib/config/env_config.dart\n'
                  '3. Check SETUP_GUIDE.md',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 