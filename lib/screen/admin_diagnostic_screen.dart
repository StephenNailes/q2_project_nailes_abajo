import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../components/dashboard/admin_dashboard_drawer.dart';

/// Admin Diagnostic Screen
/// Shows Firebase UID and admin status to help with setup
class AdminDiagnosticScreen extends StatefulWidget {
  const AdminDiagnosticScreen({super.key});

  @override
  State<AdminDiagnosticScreen> createState() => _AdminDiagnosticScreenState();
}

class _AdminDiagnosticScreenState extends State<AdminDiagnosticScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isLoading = true;
  String? _firebaseUid;
  String? _userEmail;
  String? _userName;
  bool _isAdmin = false;
  bool _profileExists = false;
  String? _errorMessage;
  Map<String, dynamic>? _adminDetails;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        setState(() {
          _errorMessage = 'Not logged in';
          _isLoading = false;
        });
        return;
      }

      // Get Firebase info
      _firebaseUid = user.uid;
      _userEmail = user.email;
      _userName = user.displayName;

      // Check if user profile exists in Supabase
      final profile = await _supabaseService.getUserProfile(user.uid);
      _profileExists = profile != null;

      // Check admin status
      _isAdmin = await _supabaseService.isUserAdmin(user.uid, forceRefresh: true);
      
      // Get admin details if admin
      if (_isAdmin) {
        _adminDetails = await _supabaseService.getAdminUser(user.uid);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }

  String _generateSqlScript() {
    if (_firebaseUid == null || _userEmail == null) {
      return '-- Error: Not logged in';
    }

    return '''
-- =====================================================
-- Admin Setup SQL Script
-- Generated on: ${DateTime.now().toIso8601String()}
-- =====================================================

-- Step 1: Ensure user profile exists
INSERT INTO public.user_profiles (id, name, email, total_disposed, created_at, updated_at)
VALUES (
  '$_firebaseUid',
  '${_userName ?? 'Admin User'}',
  '$_userEmail',
  0,
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    email = EXCLUDED.email;

-- Step 2: Grant super admin privileges
INSERT INTO public.admin_users (id, user_id, role, permissions, created_at)
VALUES (
  gen_random_uuid(),
  '$_firebaseUid',
  'super_admin',
  ARRAY['manage_videos', 'manage_articles', 'manage_users']::text[],
  NOW()
)
ON CONFLICT (user_id) DO UPDATE
SET role = 'super_admin',
    permissions = ARRAY['manage_videos', 'manage_articles', 'manage_users']::text[];

-- Step 3: Verify admin setup
SELECT 
  up.id AS firebase_uid,
  up.name,
  up.email,
  au.role,
  au.permissions,
  au.created_at AS admin_since
FROM public.user_profiles up
LEFT JOIN public.admin_users au ON au.user_id = up.id
WHERE up.id = '$_firebaseUid';
''';
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
        drawer: _isAdmin ? const AdminDashboardDrawer(currentRoute: '/admin-diagnostic') : null,
        appBar: AppBar(
          title: const Text(
            'Admin Diagnostics',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _isAdmin ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          leading: _isAdmin ? null : IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDiagnostics,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _isAdmin ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use this information to set up admin access in Supabase',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null)
                      _buildErrorCard(_errorMessage!),

                    // Firebase UID (most important!)
                    if (_firebaseUid != null)
                      _buildInfoCard(
                        icon: Icons.fingerprint,
                        iconColor: const Color(0xFF3498DB),
                        title: 'Firebase UID',
                        subtitle: 'Your unique Firebase user identifier',
                        value: _firebaseUid!,
                        isImportant: true,
                        onCopy: () => _copyToClipboard(_firebaseUid!),
                      ),

                    const SizedBox(height: 16),

                    // Email
                    if (_userEmail != null)
                      _buildInfoCard(
                        icon: Icons.email,
                        iconColor: const Color(0xFF9B59B6),
                        title: 'Email',
                        subtitle: 'Your login email address',
                        value: _userEmail!,
                        onCopy: () => _copyToClipboard(_userEmail!),
                      ),

                    const SizedBox(height: 16),

                    // Name
                    if (_userName != null)
                      _buildInfoCard(
                        icon: Icons.person,
                        iconColor: const Color(0xFF2ECC71),
                        title: 'Display Name',
                        subtitle: 'Your account name',
                        value: _userName!,
                      ),

                    const SizedBox(height: 24),

                    // Status Section
                    const Text(
                      'Account Status',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile exists status
                    _buildStatusCard(
                      icon: Icons.account_circle,
                      title: 'User Profile',
                      status: _profileExists ? 'Created' : 'Missing',
                      isGood: _profileExists,
                      message: _profileExists
                          ? 'Your profile exists in Supabase'
                          : 'Profile will be created automatically',
                    ),

                    const SizedBox(height: 16),

                    // Admin status
                    _buildStatusCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Admin Access',
                      status: _isAdmin ? 'Granted' : 'Not Granted',
                      isGood: _isAdmin,
                      message: _isAdmin
                          ? 'You have admin privileges'
                          : 'No admin privileges found',
                    ),

                    // Admin details if available
                    if (_isAdmin && _adminDetails != null) ...[
                      const SizedBox(height: 16),
                      _buildAdminDetailsCard(),
                    ],

                    const SizedBox(height: 32),

                    // SQL Script Section
                    if (!_isAdmin && _firebaseUid != null) ...[
                      const Text(
                        'Setup Instructions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionsCard(),
                      const SizedBox(height: 16),
                      _buildSqlScriptCard(),
                    ],

                    const SizedBox(height: 24),

                    // Actions
                    if (!_isAdmin)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(_generateSqlScript()),
                          icon: const Icon(Icons.content_copy),
                          label: const Text('Copy SQL Script'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    bool isImportant = false,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isImportant
            ? Border.all(color: const Color(0xFF2ECC71), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 20),
                  onPressed: onCopy,
                  tooltip: 'Copy',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String status,
    required bool isGood,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGood
                  ? const Color(0xFF2ECC71).withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isGood ? const Color(0xFF2ECC71) : Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isGood
                  ? const Color(0xFF2ECC71).withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isGood ? const Color(0xFF2ECC71) : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2ECC71)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF2ECC71), size: 24),
              SizedBox(width: 8),
              Text(
                'Admin Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Role', _adminDetails!['role'] ?? 'Unknown'),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Permissions',
            (_adminDetails!['permissions'] as List?)?.join(', ') ?? 'None',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Admin Since',
            _adminDetails!['created_at']?.toString().split('.').first ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'How to Grant Admin Access',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Copy the SQL script below\n'
            '2. Go to Supabase Dashboard → SQL Editor\n'
            '3. Paste and run the script\n'
            '4. Logout and login again\n'
            '5. Admin Console will appear in Profile',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSqlScriptCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SQL Script',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, color: Colors.white, size: 20),
                onPressed: () => _copyToClipboard(_generateSqlScript()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            _generateSqlScript(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.greenAccent,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
