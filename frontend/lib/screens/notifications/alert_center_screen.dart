import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../services/notifications/notification_service.dart';

class AlertCenterScreen extends ConsumerWidget {
  const AlertCenterScreen({super.key});

  Color _getSeverityColor(String? severity) {
    if (severity == null) return const Color(0xFF00E5FF);
    switch (severity.toUpperCase()) {
      case 'SEVERE':
      case 'CRITICAL':
        return const Color(0xFFFF007F); // Neon Red/Pink
      case 'HIGH':
        return Colors.orangeAccent;
      case 'MEDIUM':
        return Colors.yellowAccent;
      default:
        return const Color(0xFF00E5FF); // Neon Cyan
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertHistory = ref.watch(alertHistoryStreamProvider);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI ALERT CENTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF00E5FF)),
                    onPressed: () => Navigator.of(context).pushNamed('/notification-settings'),
                  ),
                ],
              ),
            ),

            // Main Alert feed
            Expanded(
              child: alertHistory.when(
                data: (snapshot) {
                  final docs = snapshot.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, color: Colors.white24, size: 50),
                          SizedBox(height: 12),
                          Text('No active smart city emergency warnings.', style: TextStyle(color: Colors.white30, fontSize: 12)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    itemBuilder: (context, idx) {
                      final doc = docs[idx];
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Emergency Notification';
                      final body = data['body'] ?? '';
                      final severityColor = _getSeverityColor(data['data']?['severity']);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 140,
                          borderRadius: 20,
                          blur: 15,
                          border: 1,
                          linearGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.03),
                              Colors.white.withOpacity(0.01),
                            ],
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              severityColor.withOpacity(0.4),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.circle, color: severityColor, size: 8),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    body,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
                error: (err, stack) => Center(child: Text('Error loading alerts: $err', style: const TextStyle(color: Colors.redAccent))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
