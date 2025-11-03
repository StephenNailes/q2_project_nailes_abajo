import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';

/// Admin navigation drawer for dashboard
class AdminDashboardDrawer extends StatelessWidget {
  final String currentRoute;
  
  const AdminDashboardDrawer({
    super.key,
    this.currentRoute = '/home',
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Admin Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 56, bottom: 32, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SUPER ADMIN',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'Admin',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Dashboard',
                    route: '/home',
                    isActive: currentRoute == '/home',
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'CONTENT MANAGEMENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.video_library_outlined,
                    title: 'Manage Videos',
                    route: '/admin/videos',
                    isActive: currentRoute.startsWith('/admin/videos'),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context,
                    icon: Icons.article_outlined,
                    title: 'Manage Articles',
                    route: '/admin/articles',
                    isActive: currentRoute.startsWith('/admin/articles'),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context,
                    icon: Icons.add_circle_outline,
                    title: 'Add Content',
                    route: '/admin/videos/add',
                    isActive: currentRoute.startsWith('/admin/videos/add') || currentRoute.startsWith('/admin/articles/add'),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'ADMIN ACCOUNT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    route: '/admin/notifications',
                    isActive: currentRoute == '/admin/notifications',
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    route: '/admin/settings',
                    isActive: currentRoute == '/admin/settings',
                  ),
                ],
              ),
            ),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  debugPrint('🔴 Admin Logout Button Pressed!');
                  
                  debugPrint('🔵 Admin Logout: Showing confirmation dialog...');
                  
                  // Show confirmation dialog (don't close drawer first!)
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout from admin account?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            debugPrint('⚪ Admin Logout: User cancelled');
                            Navigator.of(dialogContext).pop(false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('🟢 Admin Logout: User confirmed');
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFE74C3C)),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  debugPrint('🔵 Admin Logout: Dialog result: $confirmed');
                  debugPrint('🔵 Admin Logout: context.mounted = ${context.mounted}');

                  // If user confirmed logout
                  if (confirmed == true) {
                    if (!context.mounted) {
                      debugPrint('❌ Admin Logout: Context is not mounted!');
                      return;
                    }
                    
                    // Get router reference before closing drawer
                    final router = GoRouter.of(context);
                    
                    // Close drawer now that we have confirmed
                    Navigator.of(context).pop();
                    
                    try {
                      debugPrint('🔴 Admin Logout: Starting logout process...');
                      
                      // Sign out from Firebase
                      final authService = FirebaseAuthService();
                      await authService.signOut();
                      
                      debugPrint('✅ Admin Logout: Firebase signout successful');
                      
                      // Navigate using router reference (doesn't depend on context.mounted)
                      debugPrint('🔄 Admin Logout: Navigating to login screen...');
                      router.go('/login');
                      
                    } catch (e) {
                      debugPrint('❌ Admin Logout failed: $e');
                      // Show error if logout fails
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Logout failed: $e'),
                            backgroundColor: const Color(0xFFE74C3C),
                          ),
                        );
                      }
                    }
                  } else {
                    debugPrint('⚪ Admin Logout: Cancelled or dialog dismissed');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Admin Mode Badge
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Color(0xFFE74C3C), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Admin Mode Active',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFFE74C3C).withValues(alpha: 0.15) 
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive 
                ? const Color(0xFFE74C3C) 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFE74C3C) : Colors.black54,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFFE74C3C) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
