import 'package:flutter/material.dart';

class MicrophoneAnimation extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const MicrophoneAnimation({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<MicrophoneAnimation> createState() => _MicrophoneAnimationState();
}

class _MicrophoneAnimationState extends State<MicrophoneAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MicrophoneAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outward glowing pulse
            if (widget.isListening)
              Container(
                width: 70 * _glowAnimation.value,
                height: 70 * _glowAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15 * (2.0 - _glowAnimation.value)),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3 * (2.0 - _glowAnimation.value)),
                    width: 2,
                  ),
                ),
              ),
            // The main button
            GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isListening ? const Color(0xFFFF007F) : const Color(0xFF00E5FF),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isListening 
                          ? const Color(0xFFFF007F).withValues(alpha: 0.5) 
                          : const Color(0xFF00E5FF).withValues(alpha: 0.5),
                      blurRadius: widget.isListening ? 20 : 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
