import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/submission_model.dart';
import '../models/recycling_history_model.dart';
import '../models/eco_tip_model.dart';

/// Supabase Service
/// Handles all Supabase operations (auth, database, storage)
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Check if user is logged in
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Register with email and password
  Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          name: name,
        );
      }

      return response;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Login with email and password
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Create or update user profile (public method)
  /// Create or update user profile (upsert)
  Future<void> createOrUpdateUserProfile(UserModel userModel) async {
    try {
      debugPrint('🔵 SupabaseService: Creating/updating profile for ${userModel.email}');
      debugPrint('   User ID: ${userModel.id}');
      debugPrint('   Name: ${userModel.name}');
      
      // Upsert automatically uses the primary key (id) for conflict resolution
      await _client
          .from('user_profiles')
          .upsert(userModel.toSupabaseJson());
      
      debugPrint('✅ SupabaseService: Profile created/updated successfully');
    } catch (e) {
      debugPrint('❌ SupabaseService: Failed to create/update profile: $e');
      throw Exception('Failed to create/update user profile: $e');
    }
  }

  /// Create user profile
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final userModel = UserModel(
        id: userId,
        name: name,
        email: email,
        totalRecycled: 0,
        createdAt: DateTime.now(),
      );

      await _client
          .from('user_profiles')
          .insert(userModel.toSupabaseJson());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response, userId);
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
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ============================================
  // SUBMISSIONS
  // ============================================

  /// Create submission
  Future<String> createSubmission({
    required String userId,
    required String itemType,
    required int quantity,
    required String dropOffLocation,
    List<String>? photoUrls,
  }) async {
    try {
      final submission = SubmissionModel(
        id: '',
        userId: userId,
        itemType: itemType,
        quantity: quantity,
        dropOffLocation: dropOffLocation,
        photoUrls: photoUrls ?? [],
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final response = await _client
          .from('submissions')
          .insert(submission.toSupabaseJson())
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  /// Get user submissions
  Future<List<SubmissionModel>> getUserSubmissions(String userId) async {
    try {
      final response = await _client
          .from('submissions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SubmissionModel.fromJson(json, json['id']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get submissions: $e');
    }
  }

  /// Stream of user submissions
  Stream<List<SubmissionModel>> streamUserSubmissions(String userId) {
    return _client
        .from('submissions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => SubmissionModel.fromJson(json, json['id']))
            .toList());
  }

  /// Update submission status
  Future<void> updateSubmissionStatus({
    required String submissionId,
    required String status,
  }) async {
    try {
      final Map<String, dynamic> updates = {'status': status};
      
      if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }

      await _client
          .from('submissions')
          .update(updates)
          .eq('id', submissionId);
    } catch (e) {
      throw Exception('Failed to update submission status: $e');
    }
  }

  // ============================================
  // RECYCLING HISTORY
  // ============================================

  /// Add recycling history entry
  Future<void> addRecyclingHistory({
    required String userId,
    String? submissionId,
    required String itemType,
    required int quantity,
    int earnedPoints = 0,
  }) async {
    try {
      final history = RecyclingHistoryModel(
        id: '',
        userId: userId,
        submissionId: submissionId,
        itemType: itemType,
        quantity: quantity,
        earnedPoints: earnedPoints,
        recycledDate: DateTime.now(),
      );

      await _client
          .from('recycling_history')
          .insert(history.toSupabaseJson());
    } catch (e) {
      throw Exception('Failed to add recycling history: $e');
    }
  }

  /// Get user recycling history
  Future<List<RecyclingHistoryModel>> getRecyclingHistory(String userId) async {
    try {
      final response = await _client
          .from('recycling_history')
          .select()
          .eq('user_id', userId)
          .order('recycled_date', ascending: false);

      return (response as List)
          .map((json) => RecyclingHistoryModel.fromJson(json, json['id']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recycling history: $e');
    }
  }

  // ============================================
  // ECO TIPS
  // ============================================

  /// Get all eco tips
  Future<List<EcoTipModel>> getEcoTips() async {
    try {
      final response = await _client
          .from('eco_tips')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => EcoTipModel.fromJson(json, json['id']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get eco tips: $e');
    }
  }

  /// Get eco tips by category
  Future<List<EcoTipModel>> getEcoTipsByCategory(String category) async {
    try {
      final response = await _client
          .from('eco_tips')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => EcoTipModel.fromJson(json, json['id']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get eco tips by category: $e');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get total items recycled
  Future<int> getTotalItemsRecycled(String userId) async {
    try {
      final response = await _client
          .from('submissions')
          .select('quantity')
          .eq('user_id', userId)
          .eq('status', 'completed');

      int total = 0;
      for (var item in response) {
        total += (item['quantity'] as int?) ?? 0;
      }

      return total;
    } catch (e) {
      throw Exception('Failed to get total items recycled: $e');
    }
  }
}
