import os

LIB_DIR = "frontend/lib"

DART_MAIN = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase
  // await Firebase.initializeApp();
  runApp(const ProviderScope(child: ZeusApp()));
}

class ZeusApp extends StatelessWidget {
  const ZeusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZEUS Smart City',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
"""

DART_THEME = """import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF0D1117), // Deep space dark
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF), // Cyan neon
        secondary: Color(0xFFFF007F), // Magenta neon
        surface: Color(0xFF161B22),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontFamily: 'Inter', color: Colors.white70),
      ),
      // Glassmorphism default card behavior simulated via transparent colors
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
"""

DART_ROUTER = """import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/home_dashboard.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const HomeDashboard(),
    ),
    // TODO: Add other routes
  ],
);
"""

SCREEN_LOGIN = """import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ZEUS', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 8, color: Color(0xFF00E5FF))),
            const Text('SMART CITY INTELLIGENCE', style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white54)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('ENTER SYSTEM'),
            ),
          ],
        ),
      ),
    );
  }
}
"""

SCREEN_DASHBOARD = """import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZEUS DASHBOARD'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCard('Crisis Alerts', Icons.warning_amber_rounded, Colors.redAccent),
          _buildCard('Weather Intel', Icons.cloud, Colors.blueAccent),
          _buildCard('Traffic Map', Icons.map, Colors.greenAccent),
          _buildCard('AI Chatbot', Icons.chat_bubble_outline, Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
"""

files_to_write = {
    "main.dart": DART_MAIN,
    "core/theme/app_theme.dart": DART_THEME,
    "core/router/app_router.dart": DART_ROUTER,
    "screens/auth/login_screen.dart": SCREEN_LOGIN,
    "screens/dashboard/home_dashboard.dart": SCREEN_DASHBOARD,
}

for rel_path, content in files_to_write.items():
    full_path = os.path.join(LIB_DIR, rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w') as f:
        f.write(content)

print("Frontend boilerplates generated successfully.")
