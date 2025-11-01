import 'package:go_router/go_router.dart';
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
import '../screen/recycle_history_screen.dart';
import '../screen/settings_screen.dart';
import '../screen/edit_profile_screen.dart';
import '../screen/change_password_screen.dart';
import '../screen/manage_email_screen.dart';
import '../screen/notification_screen.dart';
import '../screen/connection_test_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
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
      path: '/recycle-history',
      builder: (context, state) => const RecycleHistoryScreen(),
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
  ],
);
