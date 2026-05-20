import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../providers/demo_playbook_provider.dart';

class HackathonDemoOverlay extends ConsumerStatefulWidget {
  const HackathonDemoOverlay({super.key});

  @override
  ConsumerState<HackathonDemoOverlay> createState() => _HackathonDemoOverlayState();
}

class _HackathonDemoOverlayState extends ConsumerState<HackathonDemoOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playbookState = ref.watch(demoPlaybookProvider);
    final notifier = ref.read(demoPlaybookProvider.notifier);

    // If demo is inactive, show a floating action prompt in the corner to trigger autoplay
    if (playbookState.currentStepIndex == -1) {
      return Positioned(
        bottom: 24,
        right: 24,
        child: _buildAutoplayLauncher(context, notifier),
      );
    }

    final currentStep = notifier.currentStep;
    if (currentStep == null) return const SizedBox.shrink();

    // If collapsed, show a compact floating orb
    if (playbookState.isCollapsed) {
      return Positioned(
        bottom: 24,
        right: 24,
        child: _buildCollapsedOrb(notifier, currentStep.title),
      );
    }

    final progress = 1.0 - (notifier.secondsRemaining / currentStep.duration.inSeconds);

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 165,
          borderRadius: 24,
          blur: 15,
          border: 1.5,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A).withValues(alpha: 0.9),
              const Color(0xFF020617).withValues(alpha: 0.95),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFF00E5FF).withValues(alpha: 0.4),
              const Color(0xFFFF007F).withValues(alpha: 0.2),
            ],
          ),
          child: Column(
            children: [
              // Top title & status bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: playbookState.isPlaying
                                    ? Colors.greenAccent.withValues(alpha: 0.3 + (_pulseController.value * 0.7))
                                    : Colors.orangeAccent.withValues(alpha: 0.3 + (_pulseController.value * 0.7)),
                                boxShadow: [
                                  BoxShadow(
                                    color: playbookState.isPlaying ? Colors.greenAccent : Colors.orangeAccent,
                                    blurRadius: 4 + (_pulseController.value * 6),
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DEMO PLAYBOOK STEP ${playbookState.currentStepIndex + 1}/${notifier.steps.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          currentStep.title.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.close_fullscreen, color: Colors.white54, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: notifier.toggleCollapse,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 8),

              // Cinematic Narration Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Center(
                    child: Text(
                      currentStep.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                    ),
                  ),
                ),
              ),

              // Controls Panel
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notifier.secondsRemaining}s left',
                      style: const TextStyle(color: Colors.white30, fontSize: 10, fontFamily: 'monospace'),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white70),
                          onPressed: notifier.prevStep,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (playbookState.isPlaying) {
                              notifier.pauseAutoplay();
                            } else {
                              notifier.startAutoplay();
                            }
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: playbookState.isPlaying ? const Color(0xFFFF007F) : const Color(0xFF00E5FF),
                            child: Icon(
                              playbookState.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white70),
                          onPressed: notifier.nextStep,
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: notifier.resetPlaybook,
                      child: const Text(
                        'EXIT DEMO',
                        style: TextStyle(color: Color(0xFFFF007F), fontSize: 9, fontWeight: FontWeight.bold),
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

  Widget _buildAutoplayLauncher(BuildContext context, DemoPlaybookNotifier notifier) {
    return GestureDetector(
      onTap: notifier.startAutoplay,
      child: GlassmorphicContainer(
        width: 170,
        height: 48,
        borderRadius: 24,
        blur: 15,
        border: 1.5,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.9),
            const Color(0xFF020617).withValues(alpha: 0.95),
          ],
        ),
        borderGradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFFFF007F)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, color: Color(0xFF00E5FF), size: 20),
            SizedBox(width: 8),
            Text(
              'PLAY DEMO SCENARIO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedOrb(DemoPlaybookNotifier notifier, String title) {
    return GestureDetector(
      onTap: notifier.toggleCollapse,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFFFF007F)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: const Icon(Icons.open_in_full, color: Colors.black, size: 22),
            );
          },
        ),
      ),
    );
  }
}
