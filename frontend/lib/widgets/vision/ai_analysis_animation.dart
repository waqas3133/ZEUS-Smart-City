import 'package:flutter/material.dart';

class AiAnalysisAnimation extends StatefulWidget {
  final bool isScanning;
  final Widget child;

  const AiAnalysisAnimation({
    super.key,
    required this.isScanning,
    required this.child,
  });

  @override
  State<AiAnalysisAnimation> createState() => _AiAnalysisAnimationState();
}

class _AiAnalysisAnimationState extends State<AiAnalysisAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _scanController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AiAnalysisAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning) {
      _scanController.repeat(reverse: true);
    } else {
      _scanController.stop();
      _scanController.reset();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isScanning)
          AnimatedBuilder(
            animation: _laserAnimation,
            builder: (context, child) {
              return Positioned(
                top: _laserAnimation.value * 280, // Matches standard image height
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
