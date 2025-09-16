import 'package:go_router/go_router.dart';

// Import your screens
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../screen/dashboard_screen.dart';
import '../screen/learning_hub_screen.dart';
import '../screen/eco_tips_screen.dart';
import '../screen/submission_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/recycle_history_screen.dart'; // Add this import

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
      path: '/home', // 🔄 Changed from /dashboard to /home for bottom nav
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/tips', // 🔄 Instead of /saved
      builder: (context, state) => const EcoTipsScreen(),
    ),
    GoRoute(
      path: '/guides',
      builder: (context, state) => const LearningHubScreen(),
    ),
    GoRoute(
      path: '/submissions', // plural for consistencya
      builder: (context, state) => const SubmissionScreen(),
    ),
    GoRoute(
      path: '/profile', // ✅ Added missing profile route
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/recycle-history',
      builder: (context, state) => const RecycleHistoryScreen(),
    ),
  ],
);
