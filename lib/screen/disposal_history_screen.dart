import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/components/history/disposal_history_card.dart';
import '/services/supabase_service.dart';

class DisposalHistoryScreen extends StatefulWidget {
  const DisposalHistoryScreen({super.key});

  @override
  State<DisposalHistoryScreen> createState() => _DisposalHistoryScreenState();
}

class _DisposalHistoryScreenState extends State<DisposalHistoryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  /// Load user's posts from Supabase
  Future<void> _loadUserPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final posts = await _supabaseService.getUserPosts(user.uid);
      
      setState(() {
        _userPosts = posts;
        _isLoading = false;
      });

      debugPrint('✅ Loaded ${posts.length} user posts');
    } catch (e) {
      debugPrint('❌ Error loading user posts: $e');
      setState(() {
        _errorMessage = 'Failed to load your submissions';
        _isLoading = false;
      });
    }
  }

  /// Update tracking status for a post
  Future<void> _updateTrackingStatus(String postId, String currentStatus) async {
    // Define status progression
    final statusProgression = {
      'pending': 'in_progress',
      'in_progress': 'completed',
      'completed': 'pending', // Loop back
    };

    final newStatus = statusProgression[currentStatus] ?? 'pending';

    try {
      await _supabaseService.updatePostStatus(postId, newStatus);
      
      // Update local state
      setState(() {
        final postIndex = _userPosts.indexWhere((p) => p['id'] == postId);
        if (postIndex != -1) {
          _userPosts[postIndex]['tracking_status'] = newStatus;
        }
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_getStatusDisplay(newStatus)}'),
            backgroundColor: const Color(0xFF2ECC71),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get status display text
  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Pickup';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return const Color(0xFF2ECC71);
      default:
        return Colors.grey;
    }
  }

  /// Get item icon
  IconData _getItemIcon(String itemType) {
    final lowerType = itemType.toLowerCase();
    if (lowerType.contains('phone') || lowerType.contains('smartphone')) {
      return Icons.smartphone;
    } else if (lowerType.contains('laptop') || lowerType.contains('computer')) {
      return Icons.laptop_mac;
    } else if (lowerType.contains('tablet') || lowerType.contains('ipad')) {
      return Icons.tablet_mac;
    } else if (lowerType.contains('charger') || lowerType.contains('cable')) {
      return Icons.cable;
    } else if (lowerType.contains('headphone') || lowerType.contains('earphone')) {
      return Icons.headphones;
    } else if (lowerType.contains('battery')) {
      return Icons.battery_charging_full;
    } else {
      return Icons.devices_other;
    }
  }

  /// Get item color
  Color _getItemColor(String itemType) {
    final lowerType = itemType.toLowerCase();
    if (lowerType.contains('phone')) {
      return Colors.blueAccent.shade100;
    } else if (lowerType.contains('laptop')) {
      return Colors.purpleAccent.shade100;
    } else if (lowerType.contains('tablet')) {
      return Colors.redAccent.shade100;
    } else if (lowerType.contains('charger') || lowerType.contains('cable')) {
      return Colors.greenAccent.shade100;
    } else if (lowerType.contains('headphone')) {
      return Colors.orangeAccent.shade100;
    } else {
      return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go('/profile'),
          ),
          title: const Text(
            "My Submissions",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _loadUserPosts,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadUserPosts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _userPosts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No submissions yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start submitting items for disposal or repurposing!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Track all your disposal and repurposing submissions",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: Color(0xFF2ECC71)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_userPosts.length} ${_userPosts.length == 1 ? 'submission' : 'submissions'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _loadUserPosts,
                                color: const Color(0xFF2ECC71),
                                child: ListView.separated(
                                  itemCount: _userPosts.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final post = _userPosts[index];
                                    final trackingStatus = post['tracking_status'] ?? 'pending';
                                    final itemType = post['item_type'] ?? 'Unknown';
                                    final quantity = post['quantity'] ?? 1;
                                    final location = post['drop_off_location'] ?? 'Location not specified';
                                    final createdAt = post['created_at'] != null
                                        ? DateTime.parse(post['created_at'])
                                        : DateTime.now();
                                    final photoUrls = post['photo_urls'] as List?;
                                    final firstPhoto = photoUrls != null && photoUrls.isNotEmpty
                                        ? photoUrls[0]
                                        : null;

                                    return DisposalHistoryCard(
                                      icon: _getItemIcon(itemType),
                                      bgColor: _getItemColor(itemType),
                                      title: post['brand_model'] ?? itemType,
                                      quantity: '$quantity ${quantity == 1 ? 'item' : 'items'}',
                                      location: location,
                                      date: _formatDate(createdAt),
                                      imagePath: firstPhoto,
                                      trackingStatus: trackingStatus,
                                      statusColor: _getStatusColor(trackingStatus),
                                      statusDisplay: _getStatusDisplay(trackingStatus),
                                      onStatusTap: () => _updateTrackingStatus(
                                        post['id'],
                                        trackingStatus,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
