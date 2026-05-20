import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase/firebase_service.dart' as zeus_fb;
import 'core/theme/premium_theme.dart';
import 'core/router/app_router.dart';
import 'widgets/demo/hackathon_demo_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize core Firebase platform modules
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize the Smart City Firebase Service wrapper (FCM, auth checks)
  final firebaseService = zeus_fb.FirebaseService();
  await firebaseService.initialize();

  // 3. Launch UI context
  runApp(
    const ProviderScope(
      child: ZeusApp(),
    ),
  );
}

class ZeusApp extends StatelessWidget {
  const ZeusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZEUS Smart City',
      theme: PremiumTheme.darkCyberTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Stack(
          children: [
            // ignore: use_null_aware_elements
            if (child != null) child,
            const HackathonDemoOverlay(),
          ],
        );
      },
    );
  }
}
