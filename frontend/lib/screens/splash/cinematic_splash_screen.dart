import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/theme/animation_system.dart';

class CinematicSplashScreen extends StatefulWidget {
  const CinematicSplashScreen({super.key});

  @override
  State<CinematicSplashScreen> createState() => _CinematicSplashScreenState();
}

class _CinematicSplashScreenState extends State<CinematicSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeIn)),
    );

    _controller.forward();
    _navigateToDashboard();
  }

  void _navigateToDashboard() async {
    await Future.delayed(const Duration(milliseconds: 4000));
    if (mounted) {
      context.go('/'); // Routes to AuthWrapper gateway
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.obsidianBlack,
      body: Stack(
        children: [
          // Cyber Circuit Tactical background overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1000',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Futuristic rain particle animations
          Positioned.fill(
            child: CustomPaint(
              painter: _RainParticlePainter(),
            ),
          ),

          // Central Cinematic pulsing logo
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimationSystem.pulsingGlow(
                          glowColor: PremiumTheme.neonCyan,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PremiumTheme.neonCyan.withOpacity(0.15),
                              border: Border.all(color: PremiumTheme.neonCyan, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo/zeus_logo.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'ZEUS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SMART CITY AI INTELLIGENCE',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Cinematic loading indicator
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    color: PremiumTheme.neonCyan,
                    backgroundColor: Colors.white10,
                    minHeight: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'BOOTING CYBER SYSTEMS...'.toUpperCase(),
                  style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RainParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumTheme.neonCyan.withOpacity(0.15)
      ..strokeWidth = 1.0;
    
    // Draw 30 tactical rain line particles
    final randomX = [120, 240, 450, 780, 890, 60, 310, 620, 940, 510, 800, 150, 350, 710, 90, 290, 580, 880, 400, 670];
    final randomY = [50, 150, 280, 420, 80, 320, 560, 710, 120, 480, 610, 200, 380, 640, 90, 310, 490, 730, 250, 530];

    for (int i = 0; i < randomX.length; i++) {
      final start = Offset(randomX[i].toDouble() % size.width, randomY[i].toDouble() % size.height);
      final end = Offset(start.dx - 2, start.dy + 15);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
