import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/dashboard/live_map_dashboard.dart';
import '../../widgets/dashboard/AI_logs_panel.dart';
import '../../widgets/dashboard/analytics_panel.dart';
import '../../widgets/dashboard/simulation_control_panel.dart';
import '../../widgets/dashboard/emergency_monitor_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090C),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tactical Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => context.go('/dashboard'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ZEUS SMART CITY COMMAND MONITOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E5FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'GRID STABILITY OPTIMAL | MULTI-AGENT SWARMS RUNNING',
                            style: TextStyle(color: Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Quick stats summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text(
                      'SECURE ADMIN ACCESS',
                      style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Interactive dashboard body
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Live Map & Real-time Analytics metrics)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Live digital twin map overlay
                          const Expanded(
                            flex: 3,
                            child: LiveMapDashboard(),
                          ),
                          const SizedBox(height: 20),
                          
                          // Smart analytics indicators
                          const Expanded(
                            flex: 1,
                            child: AnalyticsPanel(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Right Column (Simulation controller & rolling AI logs)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // Ticking report summary logs
                          const Expanded(
                            flex: 4,
                            child: EmergencyMonitorWidget(),
                          ),
                          const SizedBox(height: 20),
                          
                          // WebSockets Terminal rolling decisions logs
                          const Expanded(
                            flex: 4,
                            child: AiLogsPanel(),
                          ),
                          const SizedBox(height: 20),

                          // Crisis tuner panel
                          const Expanded(
                            flex: 5,
                            child: SimulationControlPanel(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
