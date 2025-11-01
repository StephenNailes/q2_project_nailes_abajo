import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for admin panel
/// Handles all database operations for content management
class AdminSupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========================================
  // AUTHENTICATION
  // ========================================

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    if (currentUserId == null) return false;
    
    try {
      final response = await _supabase
          .from('admin_users')
          .select()
          .eq('user_id', currentUserId!)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get admin user details
  Future<Map<String, dynamic>?> getAdminUser() async {
    if (currentUserId == null) return null;
    
    return await _supabase
        .from('admin_users')
        .select()
        .eq('user_id', currentUserId!)
        .maybeSingle();
  }

  // ========================================
  // VIDEOS MANAGEMENT
  // ========================================

  /// Get all videos with optional filtering
  Future<List<Map<String, dynamic>>> getVideos({
    String? category,
    bool? isFeatured,
    String? searchQuery,
    int limit = 100,
  }) async {
    var query = _supabase
        .from('videos')
        .select();

    if (category != null) {
      query = query.eq('category', category);
    }
    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single video by ID
  Future<Map<String, dynamic>> getVideo(dynamic id) async {
    return await _supabase
        .from('videos')
        .select()
        .eq('id', id)
        .single();
  }

  /// Add new video
  Future<Map<String, dynamic>> addVideo({
    required String title,
    required String description,
    required String youtubeVideoId,
    required String category,
    required String duration,
    required String author,
    String? thumbnailUrl,
    List<String>? tags,
    bool isFeatured = false,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'youtube_video_id': youtubeVideoId,
      'thumbnail_url': thumbnailUrl ?? 'https://img.youtube.com/vi/$youtubeVideoId/maxresdefault.jpg',
      'category': category,
      'duration': duration,
      'author': author,
      'tags': tags ?? [],
      'is_featured': isFeatured,
      'views': 0,
    };

    return await _supabase
        .from('videos')
        .insert(data)
        .select()
        .single();
  }

  /// Update video
  Future<Map<String, dynamic>> updateVideo(
    dynamic id,
    Map<String, dynamic> updates,
  ) async {
    return await _supabase
        .from('videos')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
  }

  /// Delete video
  Future<void> deleteVideo(dynamic id) async {
    await _supabase
        .from('videos')
        .delete()
        .eq('id', id);
  }

  // ========================================
  // ARTICLES MANAGEMENT
  // ========================================

  /// Get all articles with optional filtering
  Future<List<Map<String, dynamic>>> getArticles({
    String? category,
    bool? isFeatured,
    String? searchQuery,
    int limit = 100,
  }) async {
    var query = _supabase
        .from('articles')
        .select();

    if (category != null) {
      query = query.eq('category', category);
    }
    if (isFeatured != null) {
      query = query.eq('is_featured', isFeatured);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get single article by ID
  Future<Map<String, dynamic>> getArticle(dynamic id) async {
    return await _supabase
        .from('articles')
        .select()
        .eq('id', id)
        .single();
  }

  /// Add new article
  Future<Map<String, dynamic>> addArticle({
    required String title,
    required String description,
    required String content,
    required String category,
    required String author,
    String? heroImageUrl,
    List<String>? tags,
    int? readingTimeMinutes,
    bool isFeatured = false,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'content': content,
      'hero_image_url': heroImageUrl,
      'category': category,
      'author': author,
      'reading_time_minutes': readingTimeMinutes,
      'tags': tags ?? [],
      'is_featured': isFeatured,
      'views': 0,
    };

    return await _supabase
        .from('articles')
        .insert(data)
        .select()
        .single();
  }

  /// Update article
  Future<Map<String, dynamic>> updateArticle(
    dynamic id,
    Map<String, dynamic> updates,
  ) async {
    return await _supabase
        .from('articles')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
  }

  /// Delete article
  Future<void> deleteArticle(dynamic id) async {
    await _supabase
        .from('articles')
        .delete()
        .eq('id', id);
  }

  // ========================================
  // ANALYTICS
  // ========================================

  /// Get total counts
  Future<Map<String, int>> getTotalCounts() async {
    final videos = await _supabase.from('videos').select();
    final articles = await _supabase.from('articles').select();
    
    return {
      'videos': videos.length,
      'articles': articles.length,
    };
  }

  /// Get total views  
  Future<Map<String, int>> getTotalViews() async {
    final videos = await _supabase.from('videos').select('views');
    final articles = await _supabase.from('articles').select('views');
    
    int videoViews = 0;
    int articleViews = 0;
    
    for (var video in videos) {
      videoViews += (video['views'] as int?) ?? 0;
    }
    
    for (var article in articles) {
      articleViews += (article['views'] as int?) ?? 0;
    }
    
    return {
      'videos': videoViews,
      'articles': articleViews,
    };
  }

  /// Get most viewed content
  Future<Map<String, List<Map<String, dynamic>>>> getMostViewed({int limit = 5}) async {
    final videos = await _supabase
        .from('videos')
        .select('id, title, views, category')
        .order('views', ascending: false)
        .limit(limit);

    final articles = await _supabase
        .from('articles')
        .select('id, title, views, category')
        .order('views', ascending: false)
        .limit(limit);

    return {
      'videos': videos,
      'articles': articles,
    };
  }

  /// Get content by category
  Future<Map<String, int>> getContentByCategory() async {
    final categories = ['smartphone', 'laptop', 'tablet', 'charger', 'battery', 'cable', 'general'];
    final result = <String, int>{};

    for (final category in categories) {
      final videoCount = await _supabase
          .from('videos')
          .select()
          .eq('category', category);
      
      final articleCount = await _supabase
          .from('articles')
          .select()
          .eq('category', category);

      result[category] = videoCount.length + articleCount.length;
    }

    return result;
  }

  /// Get recent content
  Future<List<Map<String, dynamic>>> getRecentContent({int limit = 10}) async {
    final videos = await _supabase
        .from('videos')
        .select('id, title, created_at, category')
        .order('created_at', ascending: false)
        .limit(limit ~/ 2);

    final articles = await _supabase
        .from('articles')
        .select('id, title, created_at, category')
        .order('created_at', ascending: false)
        .limit(limit ~/ 2);

    // Add type field for identification
    final allContent = [
      ...videos.map((v) => {...v, 'type': 'video'}),
      ...articles.map((a) => {...a, 'type': 'article'}),
    ];

    // Sort by created_at
    allContent.sort((a, b) {
      final aDate = DateTime.parse(a['created_at']);
      final bDate = DateTime.parse(b['created_at']);
      return bDate.compareTo(aDate);
    });

    return allContent.take(limit).toList();
  }
}
