import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/eco_bottom_nav.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../components/community/community_post_card.dart';
import '../services/supabase_service.dart';
import '../models/community_post_model.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();
  
  // Filter states
  String _selectedAction = 'All'; // All, Disposed, Repurposed
  String _selectedItemType = 'All'; // All, Smartphone, Laptop, Charger, etc.
  
  // Loading and data states
  bool _isLoading = true;
  String? _errorMessage;
  List<CommunityPostModel> _communityPosts = [];

  @override
  void initState() {
    super.initState();
    _loadCommunityPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load community posts from Supabase
  Future<void> _loadCommunityPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint('🔵 Loading community posts...');
      
      // Get Firebase user ID for liked posts
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      final postsData = await _supabaseService.getAllCommunityPosts(
        limit: 50,
        currentFirebaseUserId: firebaseUser?.uid,
      );
      
      final posts = postsData.map((data) {
        return CommunityPostModel.fromJson(
          data,
          data['id'],
          userData: data['user_data'],
          isLikedByCurrentUser: data['is_liked_by_current_user'] ?? false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _communityPosts = posts;
          _isLoading = false;
        });
        debugPrint('✅ Loaded ${posts.length} community posts');
      }
    } catch (e) {
      debugPrint('❌ Error loading community posts: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLike(String postId) async {
    if (!mounted) return;
    
    try {
      // Get current Firebase Auth user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not logged in');
      }
      final userId = firebaseUser.uid;

      // Find the post
      final postIndex = _communityPosts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = _communityPosts[postIndex];
      final isCurrentlyLiked = post.isLikedByCurrentUser;

      // Optimistic update
      setState(() {
        _communityPosts[postIndex] = post.copyWith(
          isLikedByCurrentUser: !isCurrentlyLiked,
          likesCount: post.likesCount + (isCurrentlyLiked ? -1 : 1),
        );
      });

      // Update backend
      if (isCurrentlyLiked) {
        await _supabaseService.unlikePost(postId, userId);
      } else {
        await _supabaseService.likePost(postId, userId);
        
        // Create notification for post owner (if not liking own post)
        if (userId != post.userId) {
          final currentUserProfile = await _supabaseService.getUserProfile(userId);
          await _supabaseService.createNotification(
            userId: post.userId,
            type: 'like',
            title: 'New like on your post',
            message: '${currentUserProfile?.name ?? 'Someone'} liked your ${post.itemType} disposal post',
            actorId: userId,
            actorName: currentUserProfile?.name,
            actorProfileImage: currentUserProfile?.profileImageUrl,
            relatedPostId: postId,
          );
        }
      }
      
      debugPrint('✅ Post ${isCurrentlyLiked ? 'unliked' : 'liked'} successfully');
    } catch (e) {
      debugPrint('❌ Error toggling like: $e');
      // Revert optimistic update
      await _loadCommunityPosts();
    }
  }

  Future<void> _handleDeletePost(String postId, String postUserId) async {
    if (!mounted) return;

    try {
      // Get current Firebase Auth user
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not logged in');
      }
      final userId = firebaseUser.uid;

      // Verify user owns the post
      if (userId != postUserId) {
        throw Exception('You can only delete your own posts');
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
          ),
        ),
      );

      // Optimistically remove from UI
      setState(() {
        _communityPosts.removeWhere((p) => p.id == postId);
      });

      // Delete from backend
      await _supabaseService.deletePost(postId, userId);

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Color(0xFF2ECC71),
            duration: Duration(seconds: 2),
          ),
        );
      }

      debugPrint('✅ Post deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting post: $e');

      if (mounted) {
        // Close loading dialog if open
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload posts to revert optimistic update
        await _loadCommunityPosts();
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Filter Posts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedAction = 'All';
                            _selectedItemType = 'All';
                          });
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action filter
                  const Text(
                    'Disposal Action',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Disposed', 'Repurposed'].map((action) {
                      final isSelected = _selectedAction == action;
                      return FilterChip(
                        label: Text(action),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedAction = action;
                          });
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF2ECC71) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        checkmarkColor: const Color(0xFF2ECC71),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Item type filter
                  const Text(
                    'Item Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Smartphone', 'Laptop', 'Charger', 'Tablet', 'Headphones'].map((type) {
                      final isSelected = _selectedItemType == type;
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedItemType = type;
                          });
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF2ECC71) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        checkmarkColor: const Color(0xFF2ECC71),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Filtering by: $_selectedAction ${_selectedItemType != 'All' ? '• $_selectedItemType' : ''}',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<CommunityPostModel> _getFilteredPosts() {
    return _communityPosts.where((post) {
      // Filter by action
      if (_selectedAction != 'All') {
        final actionMatch = _selectedAction.toLowerCase() == post.action.toLowerCase();
        if (!actionMatch) return false;
      }
      
      // Filter by item type
      if (_selectedItemType != 'All') {
        final typeMatch = _selectedItemType.toLowerCase() == post.itemType.toLowerCase();
        if (!typeMatch) return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeNavWrapper(
      currentIndex: 1,
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
                "Community Feed",
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
              onPressed: () => context.push('/notifications'),
              tooltip: 'Notifications',
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black87),
              onPressed: () => context.push('/settings'),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load posts',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCommunityPosts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
          onRefresh: _loadCommunityPosts,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _getFilteredPosts().length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header section
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Filter/Sort header
                    Row(
                      children: [
                        Text(
                          'Recent Posts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _showFilterOptions,
                          icon: Icon(
                            Icons.filter_list, 
                            size: 18,
                            color: (_selectedAction != 'All' || _selectedItemType != 'All') 
                                ? const Color(0xFF2ECC71) 
                                : null,
                          ),
                          label: Text(
                            'Filter',
                            style: TextStyle(
                              color: (_selectedAction != 'All' || _selectedItemType != 'All') 
                                  ? const Color(0xFF2ECC71) 
                                  : null,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2ECC71),
                          ),
                        ),
                      ],
                    ),
                    // Active filters display
                    if (_selectedAction != 'All' || _selectedItemType != 'All')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (_selectedAction != 'All')
                              Chip(
                                label: Text(_selectedAction),
                                onDeleted: () {
                                  if (mounted) {
                                    setState(() {
                                      _selectedAction = 'All';
                                    });
                                  }
                                },
                                backgroundColor: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontSize: 12,
                                ),
                                deleteIconColor: const Color(0xFF2ECC71),
                              ),
                            if (_selectedItemType != 'All')
                              Chip(
                                label: Text(_selectedItemType),
                                onDeleted: () {
                                  if (mounted) {
                                    setState(() {
                                      _selectedItemType = 'All';
                                    });
                                  }
                                },
                                backgroundColor: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                                labelStyle: const TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontSize: 12,
                                ),
                                deleteIconColor: const Color(0xFF2ECC71),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                );
              }

              // Community post cards
              final filteredPosts = _getFilteredPosts();
              final post = filteredPosts[index - 1];
              final firebaseUser = FirebaseAuth.instance.currentUser;
              final isOwnPost = firebaseUser?.uid == post.userId;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CommunityPostCard(
                  post: post,
                  onLike: () => _handleLike(post.id),
                  onComment: () {
                    context.push('/community/post/${post.id}/comments?ownerId=${post.userId}');
                  },
                  isOwnPost: isOwnPost,
                  onDelete: isOwnPost ? () => _handleDeletePost(post.id, post.userId) : null,
                ),
              );
            },
          ),
        ),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 1),
      ), // Scaffold
    ), // Container
  ); // SwipeNavWrapper
  }
}
