import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/eco_bottom_nav.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../components/learninghub/hub_search_bar.dart';
import '../components/learninghub/tab_switcher.dart';
import '../components/learninghub/video_card.dart';
import '../components/learninghub/video_player_screen.dart';
import '../components/learninghub/article_viewer_screen.dart';
import '../models/learning_content_model.dart';
import '../services/supabase_service.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  int _selectedTab = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _bookmarkedIds = {};
  
  // Filter state
  String? _selectedCategory; // null means "All Categories"
  
  // Loading and data states
  bool _isLoadingVideos = true;
  bool _isLoadingArticles = true;
  String? _videosError;
  String? _articlesError;
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadContent();
  }
  
  Future<void> _loadContent() async {
    await Future.wait([
      _loadVideos(),
      _loadArticles(),
    ]);
  }
  
  Future<void> _loadVideos() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVideos = true;
      _videosError = null;
    });
    
    try {
      final videos = await SupabaseService().getAllVideos();
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _isLoadingVideos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _videosError = 'Failed to load videos: $e';
        _isLoadingVideos = false;
      });
    }
  }
  
  Future<void> _loadArticles() async {
    if (!mounted) return;
    setState(() {
      _isLoadingArticles = true;
      _articlesError = null;
    });
    
    try {
      final articles = await SupabaseService().getAllArticles();
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _isLoadingArticles = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _articlesError = 'Failed to load articles: $e';
        _isLoadingArticles = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
  }
  
  void _showFilterBottomSheet() {
    final categories = [
      {'key': null, 'name': 'All Categories', 'icon': Icons.apps},
      {'key': 'smartphone', 'name': 'Smartphones', 'icon': Icons.phone_android},
      {'key': 'laptop', 'name': 'Laptops', 'icon': Icons.laptop},
      {'key': 'tablet', 'name': 'Tablets', 'icon': Icons.tablet},
      {'key': 'charger', 'name': 'Chargers', 'icon': Icons.power},
      {'key': 'battery', 'name': 'Batteries', 'icon': Icons.battery_charging_full},
      {'key': 'cable', 'name': 'Cables', 'icon': Icons.cable},
      {'key': 'general', 'name': 'General', 'icon': Icons.category},
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Color(0xFF2ECC71)),
                  const SizedBox(width: 12),
                  const Text(
                    'Filter by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Color(0xFF2ECC71)),
                      ),
                    ),
                ],
              ),
            ),
            
            // Scrollable category list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category['key'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedCategory = category['key'] as String?);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF2ECC71).withValues(alpha: 0.15)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF2ECC71)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                color: isSelected 
                                    ? const Color(0xFF2ECC71)
                                    : Colors.grey[600],
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                category['name'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected 
                                      ? const Color(0xFF2ECC71)
                                      : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2ECC71),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper: Convert database category string to enum
  ContentCategory _getCategoryEnum(String category) {
    switch (category.toLowerCase()) {
      case 'smartphone': return ContentCategory.smartphone;
      case 'laptop': return ContentCategory.laptop;
      case 'tablet': return ContentCategory.tablet;
      case 'charger': return ContentCategory.chargers;
      case 'battery': return ContentCategory.batteries;
      case 'cable': return ContentCategory.cables;
      default: return ContentCategory.general;
    }
  }
  
  // Helper: Get category display name
  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'smartphone': return 'Smartphones';
      case 'laptop': return 'Laptops';
      case 'tablet': return 'Tablets';
      case 'charger': return 'Chargers';
      case 'battery': return 'Batteries';
      case 'cable': return 'Cables';
      case 'general': return 'General';
      default: return category;
    }
  }
  
  // Helper: Convert database video data to LearningContent
  LearningContent _videoToModel(Map<String, dynamic> data) {
    // Generate YouTube thumbnail URL from video ID
    final youtubeVideoId = data['youtube_video_id']?.toString() ?? '';
    final thumbnailUrl = youtubeVideoId.isNotEmpty 
        ? 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg'  // hqdefault is most reliable
        : data['thumbnail_url']?.toString();
    
    return LearningContent(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      type: ContentType.video,
      category: _getCategoryEnum(data['category']),
      thumbnailUrl: thumbnailUrl,
      videoUrl: 'https://www.youtube.com/watch?v=$youtubeVideoId',
      duration: Duration(seconds: data['duration'] ?? 0),
      author: data['author'],
      publishedDate: DateTime.parse(data['published_date']),
      views: data['views'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['is_featured'] ?? false,
    );
  }
  
  // Helper: Convert database article data to LearningContent
  LearningContent _articleToModel(Map<String, dynamic> data) {
    return LearningContent(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      type: ContentType.article,
      category: _getCategoryEnum(data['category']),
      thumbnailUrl: data['hero_image_url'],
      articleContent: data['content'],
      author: data['author'],
      publishedDate: DateTime.parse(data['published_date']),
      views: data['views'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['is_featured'] ?? false,
    );
  }

  void _openVideo(Map<String, dynamic> videoData) {
    final video = _videoToModel(videoData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video),
      ),
    );
  }

  void _openArticle(Map<String, dynamic> articleData) {
    final article = _articleToModel(articleData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleViewerScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwipeNavWrapper(
      currentIndex: 3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset('lib/assets/images/logo.png', height: 32),
              const SizedBox(width: 8),
              Text(
                "Learning Hub",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              onPressed: () => context.go('/notifications'),
              tooltip: 'Notifications',
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black87),
              onPressed: () => context.go('/settings'),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: HubSearchBar(
                            controller: _searchController,
                            onClear: _clearSearch,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter button
                        Container(
                          decoration: BoxDecoration(
                            color: _selectedCategory != null 
                                ? const Color(0xFF2ECC71) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: _selectedCategory != null 
                                  ? Colors.white 
                                  : Colors.black87,
                            ),
                            onPressed: _showFilterBottomSheet,
                            tooltip: 'Filter by category',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TabSwitcher(
                      selectedTab: _selectedTab,
                      onTabSelected: (index) =>
                          setState(() => _selectedTab = index),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadContent,
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildVideosTab(),
                      _buildArticlesTab(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 2),
      ), // Scaffold
    ), // Container
  ); // SwipeNavWrapper
  }

  // ========================================
  // VIDEOS TAB
  // ========================================

  Widget _buildVideosTab() {
    // Show loading state
    if (_isLoadingVideos) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2ECC71),
        ),
      );
    }
    
    // Show error state
    if (_videosError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _videosError!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Apply search and category filters
    List<Map<String, dynamic>> filteredVideos = _videos;
    
    // Filter by category
    if (_selectedCategory != null) {
      filteredVideos = filteredVideos.where((v) {
        return (v['category'] as String).toLowerCase() == _selectedCategory!.toLowerCase();
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredVideos = filteredVideos.where((v) {
        final title = (v['title'] as String).toLowerCase();
        final description = (v['description'] as String).toLowerCase();
        final tags = List<String>.from(v['tags'] ?? []);
        
        return title.contains(_searchQuery) ||
               description.contains(_searchQuery) ||
               tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      }).toList();
    }
    
    // Show empty state
    if (filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No videos available yet' 
                  : 'No videos found',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Try searching by different title or topic keywords',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '"$_searchQuery"',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filteredVideos.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _searchQuery.isEmpty 
                        ? 'Video Library' 
                        : 'Search Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filteredVideos.length} video${filteredVideos.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (_selectedCategory != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCategoryDisplayName(_selectedCategory!),
                            style: const TextStyle(
                              color: Color(0xFF2ECC71),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _selectedCategory = null),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        final videoData = filteredVideos[index - 1];
        final videoId = videoData['id'];
        final video = _videoToModel(videoData);
        
        return VideoCard(
          video: video,
          onTap: () => _openVideo(videoData),
          isBookmarked: _bookmarkedIds.contains(videoId),
          onBookmark: () => _toggleBookmark(videoId),
        );
      },
    );
  }

  // ========================================
  // ARTICLES TAB
  // ========================================

  Widget _buildArticlesTab() {
    // Show loading state
    if (_isLoadingArticles) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2ECC71),
        ),
      );
    }
    
    // Show error state
    if (_articlesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _articlesError!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadArticles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Apply search and category filters
    List<Map<String, dynamic>> filteredArticles = _articles;
    
    // Filter by category
    if (_selectedCategory != null) {
      filteredArticles = filteredArticles.where((a) {
        return (a['category'] as String).toLowerCase() == _selectedCategory!.toLowerCase();
      }).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredArticles = filteredArticles.where((a) {
        final title = (a['title'] as String).toLowerCase();
        final description = (a['description'] as String).toLowerCase();
        final tags = List<String>.from(a['tags'] ?? []);
        
        return title.contains(_searchQuery) ||
               description.contains(_searchQuery) ||
               tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      }).toList();
    }
    
    // Show empty state
    if (filteredArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No articles available yet' 
                  : 'No articles found',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Try searching by different title or topic keywords',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '"$_searchQuery"',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: filteredArticles.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _searchQuery.isEmpty 
                        ? 'Featured Articles' 
                        : 'Search Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filteredArticles.length} article${filteredArticles.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (_selectedCategory != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getCategoryDisplayName(_selectedCategory!),
                            style: const TextStyle(
                              color: Color(0xFF2ECC71),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _selectedCategory = null),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        final articleData = filteredArticles[index - 1];
        final articleId = articleData['id'];
        
        // Helper function to get category icon
        IconData getCategoryIcon(String category) {
          switch (category) {
            case 'smartphone': return Icons.phone_android;
            case 'laptop': return Icons.laptop;
            case 'tablet': return Icons.tablet;
            case 'charger': return Icons.power;
            case 'battery': return Icons.battery_charging_full;
            case 'cable': return Icons.cable;
            default: return Icons.category;
          }
        }
        
        // Helper function to format category name
        String getCategoryName(String category) {
          return category.substring(0, 1).toUpperCase() + category.substring(1);
        }
        
        // Format views
        String formatViews(int views) {
          if (views >= 1000000) {
            return '${(views / 1000000).toStringAsFixed(1)}M';
          } else if (views >= 1000) {
            return '${(views / 1000).toStringAsFixed(1)}K';
          }
          return views.toString();
        }
        
        return GestureDetector(
          onTap: () => _openArticle(articleData),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getCategoryIcon(articleData['category']),
                              size: 14,
                              color: const Color(0xFF2ECC71),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              getCategoryName(articleData['category']),
                              style: const TextStyle(
                                color: Color(0xFF2ECC71),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text(
                          articleData['title'],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        articleData['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      // Metadata
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (articleData['author'] != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  articleData['author'],
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_outlined, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                '${formatViews(articleData['views'] ?? 0)} views',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Bookmark button (top right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggleBookmark(articleId),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _bookmarkedIds.contains(articleId) 
                              ? Icons.bookmark 
                              : Icons.bookmark_border,
                          color: _bookmarkedIds.contains(articleId)
                              ? const Color(0xFF2ECC71)
                              : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}