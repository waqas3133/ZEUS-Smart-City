import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../dashboard/home_dashboard.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeDashboard();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00E5FF),
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: Text(
            'Authorization Error: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
