import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyMonitorWidget extends ConsumerWidget {
  const EmergencyMonitorWidget({super.key});

  Color _getSeverityColor(String? severity) {
    if (severity == null) return const Color(0xFF00E5FF);
    switch (severity.toUpperCase()) {
      case 'SEVERE':
      case 'CRITICAL':
        return const Color(0xFFFF007F);
      case 'HIGH':
        return Colors.orangeAccent;
      default:
        return const Color(0xFF00E5FF);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Elegant Firestore connection fallback mapping
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1622),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.report_problem, color: Color(0xFFFF007F), size: 18),
                SizedBox(width: 8),
                Text(
                  'CITIZEN EMERGENCY FEED',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildIncidentRow('Urban Flooding', 'Severe water pooling reported in G-10', 'SEVERE', '10 mins ago'),
                  const Divider(color: Colors.white12, height: 20),
                  _buildIncidentRow('Road Blockage', 'Fallen tree blocking arterial lanes', 'HIGH', '22 mins ago'),
                  const Divider(color: Colors.white12, height: 20),
                  _buildIncidentRow('Severe Traffic', 'Gridlock reported near Faisal road', 'MEDIUM', '45 mins ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentRow(String title, String summary, String severity, String time) {
    final severityColor = _getSeverityColor(severity);

    return Row(
      children: [
        Container(
          width: 8,
          height: 36,
          decoration: BoxDecoration(
            color: severityColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
