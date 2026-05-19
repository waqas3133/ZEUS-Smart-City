import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class EmergencyPopupWidget extends StatelessWidget {
  final String title;
  final String description;
  final String severity;
  final List<String> actions;
  final VoidCallback onDismiss;
  final VoidCallback onBypassPressed;

  const EmergencyPopupWidget({
    super.key,
    required this.title,
    required this.description,
    required this.severity,
    required this.actions,
    required this.onDismiss,
    required this.onBypassPressed,
  });

  Color _getSeverityColor() {
    switch (severity.toUpperCase()) {
      case 'SEVERE':
      case 'CRITICAL':
        return const Color(0xFFFF007F); // Neon Red/Pink
      case 'HIGH':
        return Colors.orangeAccent;
      default:
        return const Color(0xFF00E5FF); // Neon Cyan
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 320,
            borderRadius: 24,
            blur: 20,
            border: 2,
            linearGradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.85),
                Colors.black.withOpacity(0.7),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                severityColor,
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pulse Threat Header
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: severityColor, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: severityColor, width: 1),
                        ),
                        child: Text(
                          severity,
                          style: TextStyle(
                            color: severityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Direct Safety Actions
                  const Text(
                    'RECOMMENDED ACTIONS:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      itemCount: actions.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, idx) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.shield_outlined, color: severityColor, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                actions[idx],
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: onDismiss,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white38,
                            minimumSize: const Size(0, 44),
                          ),
                          child: const Text('DISMISS'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onBypassPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: severityColor,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.navigation, size: 16),
                          label: const Text(
                            'BYPASS PATH',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
