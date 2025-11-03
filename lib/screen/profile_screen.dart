import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/eco_bottom_nav.dart';
import '../services/firebase_auth_service.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../services/firebase_storage_service.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  bool _isLoadingProfile = true;
  bool _isAdmin = false;
  String? _profileImageUrl;
  String _userName = '';
  String _userEmail = '';
  int _totalDisposed = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _isLoadingProfile = false);
        }
        return;
      }

      debugPrint('📱 Loading profile for user: ${user.uid}');

      // CRITICAL: Set loading = false and show Firebase data FIRST
      if (mounted) {
        setState(() {
          _profileImageUrl = user.photoURL;
          _userName = user.displayName ?? user.email?.split('@').first ?? 'User';
          _userEmail = user.email ?? '';
          _totalDisposed = 0;
          _isAdmin = false;
          _isLoadingProfile = false;
        });
      }

      // Load Supabase data in background (non-blocking) - DO NOT AWAIT
      Future.wait([
        _supabaseService.getUserProfile(user.uid),
        _supabaseService.isUserAdmin(user.uid),
      ]).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('⚠️ Profile fetch timed out (2s)');
          return [null, false];
        },
      ).then((results) {
        final userProfile = results[0] as UserModel?;
        final isAdmin = results[1] as bool;
        
        debugPrint('🔐 Admin status: $isAdmin');
        
        if (mounted) {
          setState(() {
            _profileImageUrl = userProfile?.profileImageUrl ?? user.photoURL;
            _userName = userProfile?.name ?? user.displayName ?? user.email?.split('@').first ?? 'User';
            _userEmail = user.email ?? '';
            _totalDisposed = userProfile?.totalDisposed ?? 0;
            _isAdmin = isAdmin;
          });
          
          debugPrint('✅ Profile loaded: $_userName');
        }
      }).catchError((e) {
        debugPrint('⚠️ Error loading profile from Supabase: $e');
        // Already have Firebase Auth fallback data set above
      });
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      if (mounted) {
        setState(() {
          // Fallback to Firebase Auth data
          final user = FirebaseAuth.instance.currentUser;
          _profileImageUrl = user?.photoURL;
          _userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
          _userEmail = user?.email ?? '';
          _totalDisposed = 0;
          _isAdmin = false;
          _isLoadingProfile = false;
        });
      }
    }
  }

  /// Force refresh profile (for pull-to-refresh)
  Future<void> _refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    debugPrint('🔄 Force refreshing profile...');

    try {
      // Force refresh from Supabase (bypass cache)
      final results = await Future.wait([
        _supabaseService.getUserProfile(user.uid, forceRefresh: true),
        _supabaseService.isUserAdmin(user.uid, forceRefresh: true),
      ]).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ Refresh timed out');
          return [null, false];
        },
      );

      if (mounted) {
        final userProfile = results[0] as UserModel?;
        final isAdmin = results[1] as bool;

        setState(() {
          if (userProfile != null) {
            _profileImageUrl = userProfile.profileImageUrl ?? user.photoURL;
            _userName = userProfile.name;
            _userEmail = user.email ?? '';
            _totalDisposed = userProfile.totalDisposed;
          }
          _isAdmin = isAdmin;
        });

        debugPrint('✅ Profile refreshed');
      }
    } catch (e) {
      debugPrint('⚠️ Refresh failed: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to update profile picture')),
        );
        return;
      }

      // Pick image from gallery
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      // Upload to Firebase Storage
      final File imageFile = File(pickedFile.path);
      final String downloadUrl = await _storageService.uploadProfilePicture(
        user.uid,
        imageFile,
      );

      // Update in Supabase
      await _supabaseService.updateUserProfile(
        userId: user.uid,
        profileImageUrl: downloadUrl,
      );

      if (!mounted) return;

      setState(() {
        _profileImageUrl = downloadUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully'),
          backgroundColor: Color(0xFF2ECC71),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2ECC71), // Green status bar
        statusBarIconBrightness: Brightness.light, // White icons
        statusBarBrightness: Brightness.dark, // For iOS
      ),
      child: SwipeNavWrapper(
        currentIndex: 4,
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
        body: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: const Color(0xFF2ECC71),
          child: ListView(
            children: [
              Column(
          children: [
            // Profile Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 56, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF5DD39E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 108,
                                height: 108,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                                  strokeWidth: 4,
                                ),
                              )
                            : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 54,
                                    backgroundImage: NetworkImage(_profileImageUrl!),
                                  )
                                : CircleAvatar(
                                    radius: 54,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 54,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                      ),
                      GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Color(0xFF2ECC71), width: 2),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.edit,
                              color: Color(0xFF2ECC71), size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isLoadingProfile ? 'Loading...' : _userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLoadingProfile ? '' : _userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_totalDisposed Items Disposed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile Options Section
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Notifications
                    _profileOption(
                      icon: Icons.notifications_none,
                      iconColor: Color(0xFFFFA726),
                      title: "Notifications",
                      onTap: () {
                        GoRouter.of(context).go('/notifications');
                      },
                    ),
                    const SizedBox(height: 14),

                    // Admin Console (conditional)
                    if (_isAdmin) ...[
                      _profileOption(
                        icon: Icons.admin_panel_settings,
                        iconColor: const Color(0xFFE74C3C),
                        title: "Admin Console",
                        onTap: () {
                          // Route admin console to the admin home (/home) to avoid duplicate Admin screens
                          GoRouter.of(context).go('/home');
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // My Submissions
                    _profileOption(
                      icon: Icons.note_alt_outlined,
                      iconColor: Color(0xFF5DADE2),
                      title: "My Submissions",
                      onTap: () {
                        GoRouter.of(context).go('/disposal-history');
                      },
                    ),
                    const SizedBox(height: 14),

                    // Settings
                    _profileOption(
                      icon: Icons.settings_outlined,
                      iconColor: Color(0xFFBB8FCE),
                      title: "Settings",
                      onTap: () {
                        GoRouter.of(context).go('/settings');
                      },
                    ),
                    const SizedBox(height: 14),

                    // Log Out
                    _profileOption(
                      icon: Icons.logout,
                      iconColor: Color(0xFFE74C3C),
                      title: "Log Out",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text("Log Out"),
                              content: const Text(
                                  "Are you sure you want to log out?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text("Log Out"),
                                  onPressed: () async {
                                    // Close the confirmation dialog first
                                    Navigator.of(dialogContext).pop();
                                    
                                    // CRITICAL FIX: Don't show loading dialog
                                    // The authStateChanges listener will immediately redirect to /login
                                    // when signOut() completes, invalidating the context
                                    // So we can't safely pop a dialog afterward
                                    
                                    try {
                                      // Sign out from Firebase Auth and Google
                                      // The authStateChanges listener in app_router.dart will
                                      // automatically redirect to /login
                                      await _authService.signOut();
                                    } catch (e) {
                                      // Only show error if logout fails AND context is still valid
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Logout failed: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
            ], // ListView children
          ), // ListView
        ), // RefreshIndicator
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 4),
      ), // Scaffold
    ), // Container
  ), // SwipeNavWrapper
  ); // AnnotatedRegion
  }

  // Improved Profile Option Card
  Widget _profileOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
