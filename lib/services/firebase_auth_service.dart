import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Firebase Authentication Service
/// Handles user authentication with Email/Password and Google Sign-In
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // ============================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ============================================

  /// Register with email and password
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // NOTE: Skipping Firestore profile creation - using Supabase instead
      // Update display name only
      if (userCredential.user != null) {
        // await _createUserProfile(
        //   userId: userCredential.user!.uid,
        //   email: email,
        //   name: name,
        // );

        // Update display name
        await userCredential.user!.updateDisplayName(name);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Login with email and password
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // ============================================
  // GOOGLE SIGN-IN
  // ============================================

  /// Sign in with Google
  /// Shows account picker only on first sign-in or after manual logout
  Future<UserCredential?> signInWithGoogle() async {
    try {
      debugPrint('🔵 FirebaseAuthService: Initiating Google Sign-In...');
      
      // Check if user is already signed in to Google
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, show account picker
      if (googleUser == null) {
        debugPrint('🔵 FirebaseAuthService: Silent sign-in failed, showing account picker...');
        googleUser = await _googleSignIn.signIn();
      } else {
        debugPrint('✅ FirebaseAuthService: Silent sign-in successful: ${googleUser.email}');
      }

      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('⚠️ FirebaseAuthService: User cancelled Google Sign-In');
        return null;
      }

      debugPrint('✅ FirebaseAuthService: Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('🔵 FirebaseAuthService: Got Google authentication tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('🔵 FirebaseAuthService: Signing in to Firebase...');
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('✅ FirebaseAuthService: Firebase sign-in successful!');
      debugPrint('   User ID: ${userCredential.user!.uid}');
      debugPrint('   Email: ${userCredential.user!.email}');
      debugPrint('   Display Name: ${userCredential.user!.displayName}');

      // NOTE: Skipping Firestore profile creation - using Supabase instead
      // Create user profile if new user
      // if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      //   await _createUserProfile(
      //     userId: userCredential.user!.uid,
      //     email: userCredential.user!.email ?? '',
      //     name: userCredential.user!.displayName ?? 'User',
      //     profileImageUrl: userCredential.user!.photoURL,
      //   );
      // }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthService: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ FirebaseAuthService: Unexpected error: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Force Google account picker (for switching accounts)
  /// Call this before signInWithGoogle() to allow user to choose a different account
  Future<void> forceAccountPicker() async {
    await _googleSignIn.signOut();
  }

  // ============================================
  // PASSWORD MANAGEMENT
  // ============================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Update email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Verify before updating email (sends verification email to new address)
      await user.verifyBeforeUpdateEmail(newEmail);

      // Note: Firestore update will happen after user verifies the new email
      // The email won't be updated immediately - user must verify first
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  // ============================================
  // USER PROFILE MANAGEMENT (DEPRECATED - Using Supabase)
  // ============================================

  // NOTE: Firestore profile methods removed - using SupabaseService instead
  // All user profile operations should use SupabaseService

  /// Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updates['name'] = name;
        await _auth.currentUser?.updateDisplayName(name);
      }

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
        await _auth.currentUser?.updatePhotoURL(profileImageUrl);
      }

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      // CRITICAL: Clear Supabase cache after signing out
      SupabaseService.clearCache();
      debugPrint('✅ Signed out and cleared Supabase cache');
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ============================================
  // ERROR HANDLING
  // ============================================

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
