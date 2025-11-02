import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'transitions.dart';

// Import your screens
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../screen/dashboard_screen.dart';
import '../screen/learning_hub_screen.dart';
import '../screen/community_feed_screen.dart'; // Changed from eco_tips_screen
import '../screen/submission_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/disposal_history_screen.dart';
import '../screen/settings_screen.dart';
import '../screen/edit_profile_screen.dart';
import '../screen/change_password_screen.dart';
import '../screen/manage_email_screen.dart';
import '../screen/notification_screen.dart';
import '../screen/connection_test_screen.dart';
import '../screen/admin/admin_dashboard_screen.dart';
import '../screen/admin/manage_videos_screen.dart';
import '../screen/admin/manage_articles_screen.dart';
import '../screen/admin/add_video_screen.dart';
import '../screen/admin/add_article_screen.dart';

/// Stream-based refresh notifier for GoRouter
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: AuthNotifier(),
  redirect: (context, state) {
    // Check if user is authenticated
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' ||
                       state.matchedLocation == '/forgot-password';

    // If user is logged in but trying to access auth screens, redirect to home
    if (isLoggedIn && isLoggingIn) {
      return '/home';
    }

    // If user is not logged in and trying to access protected screens, redirect to login
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    // No redirect needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => AppTransitions.slideHorizontal(
        state: state,
        child: const DashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/community',
      pageBuilder: (context, state) => AppTransitions.slideHorizontal(
        state: state,
        child: const CommunityFeedScreen(),
      ),
    ),
    GoRoute(
      path: '/guides',
      pageBuilder: (context, state) => AppTransitions.slideHorizontal(
        state: state,
        child: const LearningHubScreen(),
      ),
    ),
    GoRoute(
      path: '/submissions',
      pageBuilder: (context, state) => AppTransitions.slideHorizontal(
        state: state,
        child: const SubmissionScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => AppTransitions.slideHorizontal(
        state: state,
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/disposal-history',
      builder: (context, state) => const DisposalHistoryScreen(),
    ),

    // ✅ Settings and sub-screens
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/settings/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/settings/manage-email',
      builder: (context, state) => const ManageEmailScreen(),
    ),

    // ✅ Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    
    // ✅ Connection Test
    GoRoute(
      path: '/test',
      builder: (context, state) => const ConnectionTestScreen(),
    ),
    
    // ✅ Admin Panel Routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/videos',
      builder: (context, state) => const ManageVideosScreen(),
    ),
    GoRoute(
      path: '/admin/videos/add',
      builder: (context, state) => const AddVideoScreen(),
    ),
    GoRoute(
      path: '/admin/articles',
      builder: (context, state) => const ManageArticlesScreen(),
    ),
    GoRoute(
      path: '/admin/articles/add',
      builder: (context, state) => const AddArticleScreen(),
    ),
  ],
);
