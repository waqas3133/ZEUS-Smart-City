import 'package:flutter/material.dart';

class AnimationSystem {
  /// Renders a pulsing glowing neon circle for active diagnostic icons
  static Widget pulsingGlow({
    required Widget child,
    Color glowColor = const Color(0xFF00E5FF),
    Duration duration = const Duration(seconds: 2),
  }) {
    return _PulsingGlowWidget(
      glowColor: glowColor,
      duration: duration,
      child: child,
    );
  }

  /// Futuristic animated Shimmer skeleton overlay for database loadings
  static Widget animatedShimmer({
    required double width,
    required double height,
    double radius = 16,
  }) {
    return _ShimmerWidget(
      width: width,
      height: height,
      radius: radius,
    );
  }
}

class _PulsingGlowWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;

  const _PulsingGlowWidget({
    required this.child,
    required this.glowColor,
    required this.duration,
  });

  @override
  State<_PulsingGlowWidget> createState() => _PulsingGlowWidgetState();
}

class _PulsingGlowWidgetState extends State<_PulsingGlowWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.35),
                blurRadius: _glowAnimation.value,
                spreadRadius: _glowAnimation.value / 2,
              )
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerWidget({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _gradientPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientPosition,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF1E293B),
                Color(0xFF334155),
                Color(0xFF1E293B),
              ],
              stops: [
                _gradientPosition.value - 0.3,
                _gradientPosition.value,
                _gradientPosition.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
