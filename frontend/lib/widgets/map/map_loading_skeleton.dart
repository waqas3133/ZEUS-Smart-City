import 'package:flutter/material.dart';
import '../../core/theme/premium_theme.dart';

class MapLoadingSkeleton extends StatefulWidget {
  final bool hasError;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const MapLoadingSkeleton({
    super.key,
    this.hasError = false,
    this.onRetry,
    this.errorMessage,
  });

  @override
  State<MapLoadingSkeleton> createState() => _MapLoadingSkeletonState();
}

class _MapLoadingSkeletonState extends State<MapLoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.25, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: PremiumTheme.obsidianBlack,
      child: widget.hasError ? _buildErrorView() : _buildLoadingView(),
    );
  }

  Widget _buildLoadingView() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Dark grid background simulation
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ),
            ),
            
            // Map loading overlay content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulsing Radar/Map icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: PremiumTheme.neonCyan.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PremiumTheme.neonCyan.withValues(alpha: _pulseAnimation.value),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.neonCyan.withValues(alpha: _pulseAnimation.value * 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      color: PremiumTheme.neonCyan.withValues(alpha: _pulseAnimation.value + 0.3),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'INITIALIZING SMART MAP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: PremiumTheme.neonCyan.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Connecting to Google Maps Satellite Feed...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Cyberpunk loading bar
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _pulseAnimation.value + 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: PremiumTheme.neonCyan,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.neonCyan.withValues(alpha: 0.8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorView() {
    return Stack(
      children: [
        // Grid background
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
        ),
        
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: PremiumTheme.deepSpaceBlue.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: PremiumTheme.neonPink.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: PremiumTheme.neonPink.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Alert Symbol
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: PremiumTheme.neonPink.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: PremiumTheme.neonPink, width: 2),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: PremiumTheme.neonPink,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header
                const Text(
                  'MAP CONNECTION FAILURE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                Text(
                  widget.errorMessage ??
                      'The Google Maps JavaScript SDK failed to initialize. This can occur when offline, under strict network firewalls, or due to script blockages.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Diagnostics Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DIAGNOSTIC LOG:',
                        style: TextStyle(
                          color: PremiumTheme.neonPink,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target Namespace: window.google.maps\n'
                        'State: undefined (loading error or timeout)\n'
                        'Compatibility Mode: HTML/CanvasKit Fallback Active',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Retry Button
                ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: PremiumTheme.neonCyan,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: PremiumTheme.neonCyan, width: 1.5),
                    ),
                    shadowColor: PremiumTheme.neonCyan.withValues(alpha: 0.4),
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    'RETRY CONNECTION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumTheme.neonCyan
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
