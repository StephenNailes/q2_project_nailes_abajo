import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/eco_bottom_nav.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../components/dashboard/eco_tip_card.dart';
import '../components/dashboard/welcome_section.dart';
import '../components/dashboard/admin_dashboard_drawer.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../utils/responsive_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _userProfile;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint('📱 Loading profile for user: ${user.uid}');
        
        // Create temporary profile from Firebase Auth data
        final tempProfile = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? user.email?.split('@').first ?? 'User',
          totalDisposed: 0,
          createdAt: DateTime.now(),
          profileImageUrl: user.photoURL,
        );
        
        // CRITICAL: Load admin status FIRST before showing UI
        final results = await Future.wait([
          _supabaseService.getUserProfile(user.uid),
          _supabaseService.isUserAdmin(user.uid),
        ]).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('⚠️ Profile fetch timed out (3s), using Firebase Auth data');
            return [null, false];
          },
        );
        
        final profile = results[0] as UserModel?;
        final isAdmin = results[1] as bool;
        
        debugPrint('✅ Admin status loaded: $isAdmin');
        
        if (mounted) {
          setState(() {
            _userProfile = profile ?? tempProfile;
            _isAdmin = isAdmin;
            _isLoading = false; // Set loading false AFTER admin check
          });
          debugPrint('✅ Dashboard initialized. Admin: $isAdmin');
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        setState(() {
          _isLoading = false;
          // Fallback to Firebase user
          if (user != null) {
            _userProfile = UserModel(
              id: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? user.email?.split('@').first ?? 'User',
              totalDisposed: 0,
              createdAt: DateTime.now(),
              profileImageUrl: user.photoURL,
            );
          }
        });
      }
    }
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    return fullName.split(' ').first;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking admin status
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Admin users get a different UI with drawer navigation
    if (_isAdmin) {
      return _buildAdminDashboard(context);
    }
    
    // Regular users get the standard bottom nav UI
    return SwipeNavWrapper(
      currentIndex: 0,
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
                  "TechSustain",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                  onPressed: () => context.go('/notifications'),
                  tooltip: 'Notifications',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                  onPressed: () => context.go('/settings'),
                  tooltip: 'Settings',
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👋 Welcome Section
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WelcomeSection(
                              userName: _getFirstName(_userProfile?.name),
                              profileImageUrl: _userProfile?.profileImageUrl,
                            ),
                            // Admin badge
                            if (_isAdmin) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.verified_user, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'SUPER ADMIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                  const SizedBox(height: 24),

                  // Stats Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Items Disposed',
                          value: _userProfile?.totalDisposed.toString() ?? '0',
                          icon: Icons.recycling,
                          color: const Color(0xFF2ECC71),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Locations Visited',
                          value: '0',
                          icon: Icons.location_on_outlined,
                          color: const Color(0xFFF39C12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 12),
                  
                  // Admin-specific quick actions
                  if (_isAdmin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            title: 'Admin Console',
                            icon: Icons.admin_panel_settings,
                            color: const Color(0xFFE74C3C),
                            onTap: () => context.go('/admin'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            title: 'Add Content',
                            icon: Icons.add_circle_outline,
                            color: const Color(0xFF3498DB),
                            onTap: () => context.go('/admin/videos/add'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Regular user quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: 'Dispose Item',
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFF2ECC71),
                          onTap: () => context.go('/submissions'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          title: 'Learning Hub',
                          icon: Icons.school_outlined,
                          color: const Color(0xFF9B59B6),
                          onTap: () => context.go('/guides'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Eco Tips Section
                  _buildSectionHeader('Eco Tips'),
                  const SizedBox(height: 12),
                  EcoTipCarousel(
                    tips: [
                      EcoTip(
                        tip: "Switch to LED bulbs to reduce energy consumption by up to 80%",
                        icon: Icons.lightbulb_outline,
                        iconColor: Colors.orange,
                      ),
                      EcoTip(
                        tip: "Donate or dispose of old electronics responsibly to prevent harmful e-waste from ending up in landfills.",
                        icon: Icons.shopping_bag_outlined,
                        iconColor: Colors.green,
                      ),
                      EcoTip(
                        tip: "Repurpose or refurbish broken gadgets to extend their life and reduce electronic waste.",
                        icon: Icons.grass,
                        iconColor: Colors.brown,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity Section
                  _buildSectionHeader('Why Proper E-Waste Disposal Matters'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    title: 'Environmental Impact',
                    description: 'Proper e-waste disposal prevents toxic materials from contaminating our soil and water.',
                    icon: Icons.public,
                    color: const Color(0xFF27AE60),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    title: 'Resource Recovery',
                    description: 'Recycling electronics helps recover valuable materials like gold, silver, and copper.',
                    icon: Icons.autorenew,
                    color: const Color(0xFFF39C12),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    title: 'Community Health',
                    description: 'Responsible disposal protects communities from exposure to harmful chemicals.',
                    icon: Icons.favorite_outline,
                    color: const Color(0xFFE74C3C),
                  ),
                  
                  const SizedBox(height: 24), // Space for bottom nav
                ],
              ),
            ),
          ),
          floatingActionButton: const SubmissionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: const EcoBottomNavBar(currentIndex: 0),
        ),
      ),
    );
  }

  /// Build admin-specific dashboard with drawer navigation
  Widget _buildAdminDashboard(BuildContext context) {
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
          backgroundColor: const Color(0xFFE74C3C),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.verified_user, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/admin/notifications'),
                tooltip: 'Notifications',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go('/admin/settings'),
                tooltip: 'Settings',
              ),
            ),
          ],
        ),
        drawer: const AdminDashboardDrawer(currentRoute: '/home'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Welcome Section
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : WelcomeSection(
                        userName: _getFirstName(_userProfile?.name),
                        profileImageUrl: _userProfile?.profileImageUrl,
                      ),
                const SizedBox(height: 24),

                // Admin Stats Cards
                _buildSectionHeader('Admin Overview'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Items Disposed',
                        value: _userProfile?.totalDisposed.toString() ?? '0',
                        icon: Icons.recycling,
                        color: const Color(0xFF2ECC71),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Content Items',
                        value: '0',
                        icon: Icons.library_books,
                        color: const Color(0xFF3498DB),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Admin Quick Actions
                _buildSectionHeader('Admin Actions'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Manage Videos',
                        icon: Icons.video_library,
                        color: const Color(0xFF3498DB),
                        onTap: () => context.go('/admin/videos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        title: 'Manage Articles',
                        icon: Icons.article,
                        color: const Color(0xFF9B59B6),
                        onTap: () => context.go('/admin/articles'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Add Video',
                        icon: Icons.video_call,
                        color: const Color(0xFF2ECC71),
                        onTap: () => context.go('/admin/videos/add'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        title: 'Add Article',
                        icon: Icons.article_outlined,
                        color: const Color(0xFFF39C12),
                        onTap: () => context.go('/admin/articles/add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Admin System Info
                _buildInfoCard(
                  title: 'Admin Responsibilities',
                  description: 'Manage learning content, monitor user submissions, and ensure platform quality.',
                  icon: Icons.admin_panel_settings,
                  color: const Color(0xFFE74C3C),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // No bottom navigation bar for admins
      ),
    );
  }
}
