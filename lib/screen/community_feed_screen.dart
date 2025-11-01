import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/eco_bottom_nav.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../components/community/community_post_card.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Filter states
  String _selectedAction = 'All'; // All, Disposed, Repurposed
  String _selectedItemType = 'All'; // All, Smartphone, Laptop, Charger, etc.
  
  // TODO: Replace with real data from Supabase
  final List<Map<String, dynamic>> _communityPosts = [
    {
      'id': '1',
      'userId': 'user123',
      'userName': 'Sarah Chen',
      'userAvatar': 'lib/assets/images/kert.jpg',
      'itemType': 'Smartphone',
      'itemBrand': 'iPhone 12',
      'quantity': 2,
      'location': 'Green Valley Disposal Center',
      'locationAddress': '123 Eco Street, Green City',
      'action': 'Disposed',
      'images': ['lib/assets/images/apple-ip.jpg'],
      'description': 'Successfully disposed of my old iPhone 12. The staff was very helpful and explained how they will extract valuable materials responsibly!',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'likes': 24,
      'comments': 5,
      'isLiked': false,
    },
    {
      'id': '2',
      'userId': 'user456',
      'userName': 'Kert Abajo',
      'userAvatar': 'lib/assets/images/kert.jpg',
      'itemType': 'Laptop',
      'itemBrand': 'MacBook Pro 2015',
      'quantity': 1,
      'location': 'Tech Refurbish Hub',
      'locationAddress': '456 Sustainability Ave',
      'action': 'Repurposed',
      'images': ['lib/assets/images/macbook.jpg'],
      'description': 'Gave my old MacBook to Tech Refurbish Hub. They will clean it up and donate it to students in need. Feels great to give back!',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'likes': 38,
      'comments': 12,
      'isLiked': true,
    },
    {
      'id': '3',
      'userId': 'user789',
      'userName': 'Alex Johnson',
      'userAvatar': 'lib/assets/images/kert.jpg',
      'itemType': 'Charger',
      'itemBrand': 'USB-C Chargers',
      'quantity': 5,
      'location': 'EcoSustain Drop-off Point',
      'locationAddress': '789 Earth Street',
      'action': 'Disposed',
      'images': ['lib/assets/images/charger.jpg'],
      'description': 'Cleaned out my drawer and found so many old chargers! This drop-off point made it super easy.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'likes': 15,
      'comments': 3,
      'isLiked': false,
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLike(String postId) {
    if (!mounted) return;
    setState(() {
      final post = _communityPosts.firstWhere((p) => p['id'] == postId);
      post['isLiked'] = !post['isLiked'];
      post['likes'] += post['isLiked'] ? 1 : -1;
    });
    // TODO: Update like status in Supabase
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

  List<Map<String, dynamic>> _getFilteredPosts() {
    return _communityPosts.where((post) {
      // Filter by action
      if (_selectedAction != 'All' && post['action'] != _selectedAction) {
        return false;
      }
      
      // Filter by item type
      if (_selectedItemType != 'All' && post['itemType'] != _selectedItemType) {
        return false;
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
        body: RefreshIndicator(
          onRefresh: () async {
            // TODO: Refresh posts from Supabase
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              setState(() {});
            }
          },
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
                    // Create post button
                    GestureDetector(
                      onTap: () => context.go('/submissions'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: const AssetImage('lib/assets/images/kert.jpg'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F2F5),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  'Share your e-waste disposal...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Color(0xFF2ECC71),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CommunityPostCard(
                  post: post,
                  onLike: () => _handleLike(post['id']),
                  onComment: () {
                    // TODO: Navigate to comments screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comments feature coming soon!')),
                    );
                  },
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
