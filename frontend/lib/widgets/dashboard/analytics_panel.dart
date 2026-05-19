import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/demo_playbook_provider.dart';

class AnalyticsPanel extends ConsumerWidget {
  const AnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbookState = ref.watch(demoPlaybookProvider);
    final isOptimizationStep = playbookState.currentStepIndex == 5;

    final congestion = isOptimizationStep ? '18%' : '42%';
    final speed = isOptimizationStep ? '4.2 MIN' : '8.5 MIN';
    final optimization = isOptimizationStep ? '99.1%' : '94.2%';

    return Row(
      children: [
        Expanded(child: _buildMetricCard('CONGESTION SLIP', congestion, Icons.trending_down, const Color(0xFF00E5FF))),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('RESPONSE SPEED', speed, Icons.flash_on, const Color(0xFFFF007F))),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard('OPTIMIZATION INDEX', optimization, Icons.psychology, Colors.orangeAccent)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color accentColor) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 20,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.02),
          Colors.white.withOpacity(0.005),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.01),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
