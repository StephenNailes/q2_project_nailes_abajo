import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../components/dashboard/admin_dashboard_drawer.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/login');
          });
        }
        return;
      }

      final isAdmin = await _supabaseService.isUserAdmin(user.uid);
      
      if (!isAdmin) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/home');
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isAuthorized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Admin authorization error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout from admin account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE74C3C)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
            ),
          ),
        ),
      );
    }

    if (!_isAuthorized) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: Text('Access Denied')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Admin Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AdminDashboardDrawer(currentRoute: '/admin/settings'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Account Settings
            _buildSectionHeader('Account Settings'),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.person_outline,
              iconColor: const Color(0xFFE74C3C),
              title: 'Admin Profile',
              subtitle: 'Update admin information',
              onTap: () {
                // TODO: Create route: /admin/settings/edit-profile
                // Future: context.push('/admin/settings/edit-profile');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin profile editing - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF3498DB),
              title: 'Change Password',
              subtitle: 'Update admin password',
              onTap: () {
                // TODO: Create route: /admin/settings/change-password
                // Future: context.push('/admin/settings/change-password');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin password change - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFF9B59B6),
              title: 'Manage Email',
              subtitle: 'Update admin email address',
              onTap: () {
                // TODO: Create route: /admin/settings/manage-email
                // Future: context.push('/admin/settings/manage-email');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Admin email management - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 24),

            // System Settings
            _buildSectionHeader('System Settings'),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFF39C12),
              title: 'Notification Preferences',
              subtitle: 'Manage admin notifications',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.security_outlined,
              iconColor: const Color(0xFF16A085),
              title: 'Security',
              subtitle: 'Two-factor authentication, login history',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security settings - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.backup_outlined,
              iconColor: const Color(0xFF2ECC71),
              title: 'Database Backup',
              subtitle: 'Manage automated backups',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup settings - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Admin Tools
            _buildSectionHeader('Admin Tools'),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.bug_report_outlined,
              iconColor: const Color(0xFFE67E22),
              title: 'Diagnostic Tools',
              subtitle: 'View admin diagnostics',
              onTap: () {
                context.go('/admin-diagnostic');
              },
            ),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.analytics_outlined,
              iconColor: const Color(0xFF8E44AD),
              title: 'Analytics',
              subtitle: 'View platform analytics',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics - Coming soon')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionHeader('Danger Zone'),
            const SizedBox(height: 12),
            _buildSettingOption(
              icon: Icons.logout,
              iconColor: const Color(0xFFE74C3C),
              title: 'Logout',
              subtitle: 'Sign out from admin account',
              onTap: _handleLogout,
              isDanger: true,
            ),
            const SizedBox(height: 24),

            // App Info
            Center(
              child: Text(
                'Admin Panel v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE74C3C),
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDanger 
              ? const Color(0xFFE74C3C).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDanger
              ? Border.all(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                  width: 1.5,
                )
              : null,
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
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? const Color(0xFFE74C3C) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
