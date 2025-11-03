import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../components/dashboard/admin_dashboard_drawer.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() => _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  final SupabaseService _supabaseService = SupabaseService();
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
          'Admin Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AdminDashboardDrawer(currentRoute: '/admin/notifications'),
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
            // System Notifications
            _buildSectionHeader('System Notifications'),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.security,
              iconColor: const Color(0xFFE74C3C),
              title: 'Security Alert',
              message: 'Admin login detected from new device',
              time: '2 hours ago',
              isRead: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.backup,
              iconColor: const Color(0xFF3498DB),
              title: 'Database Backup',
              message: 'Automated backup completed successfully',
              time: '5 hours ago',
              isRead: true,
            ),
            const SizedBox(height: 24),

            // Content Updates
            _buildSectionHeader('Content Updates'),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.video_library,
              iconColor: const Color(0xFF9B59B6),
              title: 'New Video Added',
              message: 'Video "E-Waste Disposal Guide" was published',
              time: '1 day ago',
              isRead: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.article,
              iconColor: const Color(0xFF2ECC71),
              title: 'Article Updated',
              message: 'Article "Battery Recycling" was modified',
              time: '2 days ago',
              isRead: true,
            ),
            const SizedBox(height: 24),

            // User Activity
            _buildSectionHeader('User Activity'),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.people,
              iconColor: const Color(0xFFF39C12),
              title: 'New User Registration',
              message: '15 new users registered today',
              time: '3 hours ago',
              isRead: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.recycling,
              iconColor: const Color(0xFF16A085),
              title: 'Disposal Submission',
              message: '23 items submitted for disposal today',
              time: '6 hours ago',
              isRead: true,
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

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFE74C3C).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.transparent : const Color(0xFFE74C3C).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE74C3C),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
