import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class EmergencyRouteWidget extends StatefulWidget {
  final VoidCallback onDispatch;
  final bool isSimulating;
  final List<String> logs;

  const EmergencyRouteWidget({
    super.key,
    required this.onDispatch,
    required this.isSimulating,
    required this.logs,
  });

  @override
  State<EmergencyRouteWidget> createState() => _EmergencyRouteWidgetState();
}

class _EmergencyRouteWidgetState extends State<EmergencyRouteWidget> with SingleTickerProviderStateMixin {
  late AnimationController _sirenController;
  bool _sirenActive = false;

  @override
  void initState() {
    super.initState();
    _sirenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sirenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 220,
      borderRadius: 24,
      blur: 15,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.85),
          Colors.black.withValues(alpha: 0.65),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFFFF007F).withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Row
            Row(
              children: [
                // Dispatch Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onDispatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isSimulating ? const Color(0xFFFF007F) : const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      widget.isSimulating ? Icons.stop_circle : Icons.local_fire_department,
                      color: Colors.black,
                    ),
                    label: Text(
                      widget.isSimulating ? 'HALT SIMULATION' : 'EMERGENCY DISPATCH',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Siren Toggle Button
                AnimatedBuilder(
                  animation: _sirenController,
                  builder: (context, child) {
                    final colorVal = _sirenActive 
                        ? Color.lerp(const Color(0xFFFF007F), const Color(0xFF00E5FF), _sirenController.value) 
                        : Colors.white24;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _sirenActive = !_sirenActive;
                        });
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorVal?.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorVal ?? Colors.white24, width: 2),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: colorVal,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Live Swarm reasoning log
            const Text(
              'LIVE AI SWARM REASONING LOGS:',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: widget.logs.isEmpty
                    ? const Center(
                        child: Text(
                          'No dispatch active. Waiting for trigger...',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.logs.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          // Reverse index to show new logs at the top
                          final log = widget.logs[widget.logs.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '⚡ ',
                                  style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
                                ),
                                Expanded(
                                  child: Text(
                                    log,
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
