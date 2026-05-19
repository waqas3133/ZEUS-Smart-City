import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName?.toUpperCase() ?? "CITIZEN";

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF07090C),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header with profile actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME BACK,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white30),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFFFF007F)],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 30),

                // AI Status Core Box (Glassmorphic)
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 90,
                  borderRadius: 20,
                  blur: 15,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.04),
                      Colors.white.withOpacity(0.01),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      const Color(0xFF00E5FF).withOpacity(0.3),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Color(0xFF00E5FF), size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ZEUS COMMAND NETWORK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'All agents active. Edge telemetry stream synced.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  'CRISIS INTELLIGENCE MODULES',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Menu Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildGridCard(
                        context,
                        title: 'Live Threat Map',
                        subtitle: 'Real-time hazard pins',
                        icon: Icons.map_outlined,
                        color: const Color(0xFF00E5FF),
                        route: '/live-map',
                      ),
                      _buildGridCard(
                        context,
                        title: 'Traffic Control',
                        subtitle: 'Bypass route simulations',
                        icon: Icons.alt_route_outlined,
                        color: const Color(0xFF00E5FF),
                        route: '/traffic-intelligence',
                      ),
                      _buildGridCard(
                        context,
                        title: 'AI Chatbot',
                        subtitle: 'Roman Urdu assistant',
                        icon: Icons.chat_bubble_outline,
                        color: const Color(0xFFFF007F),
                        route: '/ai-chatbot',
                      ),
                      _buildGridCard(
                        context,
                        title: 'Report Incident',
                        subtitle: 'Camera AI scanner',
                        icon: Icons.add_a_photo_outlined,
                        color: const Color(0xFFFF007F),
                        route: '/emergency-upload',
                      ),
                      _buildGridCard(
                        context,
                        title: 'Alert Center',
                        subtitle: 'Crisis notification log',
                        icon: Icons.notifications_none_outlined,
                        color: Colors.amberAccent,
                        route: '/alert-center',
                      ),
                      _buildGridCard(
                        context,
                        title: 'Preferences',
                        subtitle: 'Geofence limits tuner',
                        icon: Icons.tune_outlined,
                        color: Colors.white54,
                        route: '/notification-settings',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 15,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.04),
            Colors.white.withOpacity(0.01),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.02),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
