import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/submission_model.dart';
import '../models/disposal_history_model.dart';
import '../models/eco_tip_model.dart';

/// Supabase Service
/// Handles all Supabase operations (auth, database, storage)
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ============================================
  // PROFILE CACHE - Prevents redundant API calls
  // ============================================
  static UserModel? _cachedProfile;
  static bool? _cachedAdminStatus;
  static String? _cachedUserId;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Clear the profile cache (call on logout or profile update)
  static void clearCache() {
    _cachedProfile = null;
    _cachedAdminStatus = null;
    _cachedUserId = null;
    _cacheTimestamp = null;
    debugPrint('🗑️ Profile cache cleared');
  }

  /// Check if cache is valid
  static bool _isCacheValid(String userId) {
    if (_cachedUserId != userId) return false;
    if (_cacheTimestamp == null) return false;
    final elapsed = DateTime.now().difference(_cacheTimestamp!);
    return elapsed < _cacheExpiration;
  }

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
  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Clear cache on logout
      clearCache();
      debugPrint('✅ Signed out and cache cleared');
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
        totalDisposed: 0,
        createdAt: DateTime.now(),
      );

      await _client
          .from('user_profiles')
          .insert(userModel.toSupabaseJson());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile (with caching)
  Future<UserModel?> getUserProfile(String userId, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && _isCacheValid(userId) && _cachedProfile != null) {
      debugPrint('💾 Using cached profile for user: $userId');
      return _cachedProfile;
    }

    try {
      debugPrint('🔵 SupabaseService: Fetching profile for user: $userId');
      
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              debugPrint('⚠️ SupabaseService: Profile fetch timed out (2s)');
              return null;
            },
          );

      if (response == null) {
        debugPrint('⚠️ SupabaseService: No profile found for user: $userId');
        // Try to get user info from Firebase Auth and create profile
        final user = _client.auth.currentUser;
        if (user != null) {
          debugPrint('🔵 Creating profile for user from auth data...');
          final name = user.userMetadata?['name'] as String? ?? 
                      user.email?.split('@').first ?? 
                      'User';
          final email = user.email ?? '';
          
          try {
            // Create profile (with aggressive timeout)
            await _createUserProfile(
              userId: userId,
              email: email,
              name: name,
            ).timeout(const Duration(seconds: 2));
            
            // Fetch the newly created profile (short timeout)
            final newProfile = await _client
                .from('user_profiles')
                .select()
                .eq('id', userId)
                .maybeSingle()
                .timeout(const Duration(seconds: 1));
                
            if (newProfile != null) {
              final profile = UserModel.fromJson(newProfile, userId);
              // Cache the newly created profile
              _cachedProfile = profile;
              _cachedUserId = userId;
              _cacheTimestamp = DateTime.now();
              return profile;
            }
          } catch (e) {
            debugPrint('⚠️ Failed to create profile: $e');
            return null;
          }
        }
        return null;
      }

      final profile = UserModel.fromJson(response, userId);
      
      // Cache the profile
      _cachedProfile = profile;
      _cachedUserId = userId;
      _cacheTimestamp = DateTime.now();
      debugPrint('✅ Profile cached for user: $userId');
      
      return profile;
    } catch (e) {
      debugPrint('❌ SupabaseService: Failed to get user profile: $e');
      return null; // Return null instead of throwing to allow app to function
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
      
      // Clear cache after update
      clearCache();
      debugPrint('✅ Profile updated and cache cleared');
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
  // DISPOSAL HISTORY
  // ============================================

  /// Add disposal history entry
  Future<void> addDisposalHistory({
    required String userId,
    String? submissionId,
    required String itemType,
    required int quantity,
    int earnedPoints = 0,
  }) async {
    try {
      final history = DisposalHistoryModel(
        id: '',
        userId: userId,
        submissionId: submissionId,
        itemType: itemType,
        quantity: quantity,
        earnedPoints: earnedPoints,
        disposedDate: DateTime.now(),
      );

      await _client
          .from('disposal_history')
          .insert(history.toSupabaseJson());
    } catch (e) {
      throw Exception('Failed to add disposal history: $e');
    }
  }

  /// Get user disposal history
  Future<List<DisposalHistoryModel>> getDisposalHistory(String userId) async {
    try {
      final response = await _client
          .from('disposal_history')
          .select()
          .eq('user_id', userId)
          .order('disposed_date', ascending: false);

      return (response as List)
          .map((json) => DisposalHistoryModel.fromJson(json, json['id']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get disposal history: $e');
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

  /// Get total items disposed
  Future<int> getTotalItemsDisposed(String userId) async {
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
      throw Exception('Failed to get total items disposed: $e');
    }
  }

  // ============================================
  // LEARNING CONTENT - VIDEOS
  // ============================================

  /// Get all videos
  Future<List<Map<String, dynamic>>> getAllVideos() async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .order('published_date', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get videos: $e');
    }
  }

  /// Get videos by category
  Future<List<Map<String, dynamic>>> getVideosByCategory(String category) async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .eq('category', category)
          .order('published_date', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get videos by category: $e');
    }
  }

  /// Get featured videos
  Future<List<Map<String, dynamic>>> getFeaturedVideos() async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .eq('is_featured', true)
          .order('views', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get featured videos: $e');
    }
  }

  /// Search videos by title, description, or tags
  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('views', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }

  /// Get video by ID
  Future<Map<String, dynamic>?> getVideoById(String id) async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get video: $e');
    }
  }

  /// Increment video views
  Future<void> incrementVideoViews(String videoId) async {
    try {
      final currentVideo = await _client
          .from('videos')
          .select('views')
          .eq('id', videoId)
          .single();

      final currentViews = (currentVideo['views'] as int?) ?? 0;

      await _client
          .from('videos')
          .update({'views': currentViews + 1})
          .eq('id', videoId);
    } catch (e) {
      debugPrint('Failed to increment video views: $e');
    }
  }

  /// Add a new video (admin only)
  Future<String> addVideo({
    required String title,
    required String description,
    required String youtubeVideoId,
    String? thumbnailUrl,
    required String category,
    required int duration,
    required String author,
    List<String>? tags,
    bool isFeatured = false,
  }) async {
    try {
      final response = await _client
          .from('videos')
          .insert({
            'title': title,
            'description': description,
            'youtube_video_id': youtubeVideoId,
            'thumbnail_url': thumbnailUrl ?? 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg',
            'category': category,
            'duration': duration,
            'author': author,
            'tags': tags ?? [],
            'is_featured': isFeatured,
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to add video: $e');
    }
  }

  /// Update video (admin only)
  Future<void> updateVideo(String id, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('videos')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update video: $e');
    }
  }

  /// Delete video (admin only)
  Future<void> deleteVideo(String id) async {
    try {
      await _client
          .from('videos')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }

  // ============================================
  // LEARNING CONTENT - ARTICLES
  // ============================================

  /// Get all articles
  Future<List<Map<String, dynamic>>> getAllArticles() async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .order('published_date', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get articles: $e');
    }
  }

  /// Get articles by category
  Future<List<Map<String, dynamic>>> getArticlesByCategory(String category) async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .eq('category', category)
          .order('published_date', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get articles by category: $e');
    }
  }

  /// Get featured articles
  Future<List<Map<String, dynamic>>> getFeaturedArticles() async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .eq('is_featured', true)
          .order('views', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to get featured articles: $e');
    }
  }

  /// Search articles by title, description, or tags
  Future<List<Map<String, dynamic>>> searchArticles(String query) async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('views', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to search articles: $e');
    }
  }

  /// Get article by ID
  Future<Map<String, dynamic>?> getArticleById(String id) async {
    try {
      final response = await _client
          .from('articles')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get article: $e');
    }
  }

  /// Increment article views
  Future<void> incrementArticleViews(String articleId) async {
    try {
      final currentArticle = await _client
          .from('articles')
          .select('views')
          .eq('id', articleId)
          .single();

      final currentViews = (currentArticle['views'] as int?) ?? 0;

      await _client
          .from('articles')
          .update({'views': currentViews + 1})
          .eq('id', articleId);
    } catch (e) {
      debugPrint('Failed to increment article views: $e');
    }
  }

  /// Add a new article (admin only)
  Future<String> addArticle({
    required String title,
    required String description,
    required String content,
    String? heroImageUrl,
    required String category,
    required String author,
    List<String>? tags,
    bool isFeatured = false,
  }) async {
    try {
      final response = await _client
          .from('articles')
          .insert({
            'title': title,
            'description': description,
            'content': content,
            'hero_image_url': heroImageUrl,
            'category': category,
            'author': author,
            'tags': tags ?? [],
            'is_featured': isFeatured,
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to add article: $e');
    }
  }

  /// Update article (admin only)
  Future<void> updateArticle(String id, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('articles')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update article: $e');
    }
  }

  /// Delete article (admin only)
  Future<void> deleteArticle(String id) async {
    try {
      await _client
          .from('articles')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete article: $e');
    }
  }

  // ============================================
  // ADMIN MANAGEMENT
  // ============================================

  /// Check if user is admin
  /// Check if user is admin (with caching)
  Future<bool> isUserAdmin(String userId, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh && _isCacheValid(userId) && _cachedAdminStatus != null) {
      debugPrint('💾 Using cached admin status for user: $userId');
      return _cachedAdminStatus!;
    }

    try {
      debugPrint('🔵 SupabaseService: Checking admin status for user: $userId');
      
      final response = await _client
          .from('admin_users')
          .select()
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              debugPrint('⚠️ Admin check timed out (2s)');
              return null;
            },
          );

      final isAdmin = response != null;
      
      // Cache the admin status
      _cachedAdminStatus = isAdmin;
      if (_cachedUserId == null) {
        _cachedUserId = userId;
        _cacheTimestamp = DateTime.now();
      }
      
      debugPrint('✅ Admin status cached: $isAdmin');
      return isAdmin;
    } catch (e) {
      debugPrint('⚠️ Failed to check admin status: $e');
      return false;
    }
  }

  /// Get admin user details
  Future<Map<String, dynamic>?> getAdminUser(String userId) async {
    try {
      final response = await _client
          .from('admin_users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }
}

