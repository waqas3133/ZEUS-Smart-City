import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/splash/cinematic_splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/auth_wrapper.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/location_permission_screen.dart';
import '../../screens/dashboard/home_dashboard.dart';
import '../../screens/map/live_map_screen.dart';
import '../../screens/map/smart_map_screen.dart';
import '../../screens/chatbot/ai_chatbot_screen.dart';
import '../../screens/vision/emergency_upload_screen.dart';
import '../../screens/notifications/alert_center_screen.dart';
import '../../screens/notifications/notification_settings_screen.dart';
import '../../screens/dashboard/admin_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/splash' ||
        state.matchedLocation == '/onboarding';

    if (user == null && !isAuthRoute) {
      return '/login';
    }
    if (user != null && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const CinematicSplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/location-permission',
      builder: (context, state) => const LocationPermissionScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const HomeDashboard(),
    ),
    GoRoute(
      path: '/live-map',
      builder: (context, state) => const LiveMapScreen(),
    ),
    GoRoute(
      path: '/traffic-intelligence',
      builder: (context, state) => const SmartMapScreen(),
    ),
    GoRoute(
      path: '/ai-chatbot',
      builder: (context, state) => const AiChatbotScreen(),
    ),
    GoRoute(
      path: '/emergency-upload',
      builder: (context, state) => const EmergencyUploadScreen(),
    ),
    GoRoute(
      path: '/alert-center',
      builder: (context, state) => const AlertCenterScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
