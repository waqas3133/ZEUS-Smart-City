import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_assets_structure.dart';
import 'onboarding_controller.dart';
import '../../core/theme/premium_theme.dart';
import '../../core/theme/animation_system.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(onboardingProvider.notifier).setPage(index);
    _fadeController.reset();
    _fadeController.forward();
  }

  void _handleNext(int currentIndex) {
    if (currentIndex < OnboardingAssets.pages.length - 1) {
      _onPageChanged(currentIndex + 1);
    } else {
      _finishOnboarding();
    }
  }

  void _handleBack(int currentIndex) {
    if (currentIndex > 0) {
      _onPageChanged(currentIndex - 1);
    }
  }

  void _handleSkip() {
    _onPageChanged(OnboardingAssets.pages.length - 1);
  }

  void _finishOnboarding() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.go('/'); // Navigate to AuthWrapper gateway
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final currentIndex = onboardingState.currentPageIndex;
    final currentPageData = OnboardingAssets.pages[currentIndex];
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    return Scaffold(
      backgroundColor: PremiumTheme.obsidianBlack,
      body: Stack(
        children: [
          // Background Dynamic Image with Slow Cinematic Zoom/Opacity
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Image.network(
                currentPageData.imageUrl,
                key: ValueKey<String>(currentPageData.imageUrl),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: PremiumTheme.obsidianBlack,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: PremiumTheme.neonCyan,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Dark Futuristic Glass Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PremiumTheme.obsidianBlack.withValues(alpha: 0.4),
                    PremiumTheme.obsidianBlack.withValues(alpha: 0.85),
                    PremiumTheme.obsidianBlack,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Cyber Grid Visual Element
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(gridColor: currentPageData.accentColor.withValues(alpha: 0.08)),
            ),
          ),

          // Main Responsive Content Area
          SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1100 : (isTablet ? 700 : double.infinity),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Header Bar (Brand & Skip)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPageData.accentColor.withValues(alpha: 0.15),
                                border: Border.all(color: currentPageData.accentColor, width: 1.5),
                              ),
                              child: Icon(
                                Icons.bolt,
                                color: currentPageData.accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'ZEUS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        if (currentIndex < OnboardingAssets.pages.length - 1)
                          TextButton(
                            onPressed: _handleSkip,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white60,
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'SKIP SYSTEM',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_double_arrow_right, size: 14),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Middle content (Flexible page view / details)
                    Expanded(
                      child: isDesktop
                          ? _buildDesktopLayout(currentPageData, isDesktop)
                          : _buildMobileLayout(currentPageData),
                    ),

                    // Footer navigation controls
                    _buildFooterControls(currentIndex, currentPageData),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop side-by-side splits
  Widget _buildDesktopLayout(OnboardingPageData data, bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Interactive Cybernetic Visual Frame
        Expanded(
          flex: 5,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hexagonal background outline
                  AnimationSystem.pulsingGlow(
                    glowColor: data.accentColor,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.accentColor.withValues(alpha: 0.05),
                        border: Border.all(color: data.accentColor.withValues(alpha: 0.3), width: 2),
                      ),
                    ),
                  ),
                  // Rotating tactical overlay lines
                  RotationTransition(
                    turns: const AlwaysStoppedAnimation(45 / 360),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: data.accentColor.withValues(alpha: 0.15), width: 1.5),
                      ),
                    ),
                  ),
                  // Core cinematic icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTheme.obsidianBlack,
                      border: Border.all(color: data.accentColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: data.accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      color: data.accentColor,
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Right Column: Glassmorphic description details
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: _buildTextCard(data, isDesktop: true),
          ),
        ),
      ],
    );
  }

  // Mobile stacked screen layout
  Widget _buildMobileLayout(OnboardingPageData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing cinematic Center Visual
        Expanded(
          flex: 4,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimationSystem.pulsingGlow(
                    glowColor: data.accentColor,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: data.accentColor.withValues(alpha: 0.05),
                        border: Border.all(color: data.accentColor.withValues(alpha: 0.2), width: 1.5),
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumTheme.obsidianBlack,
                      border: Border.all(color: data.accentColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: data.accentColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      color: data.accentColor,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Text Card
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: _buildTextCard(data, isDesktop: false),
          ),
        ),
      ],
    );
  }

  // Common glassmorphic info presentation card
  Widget _buildTextCard(OnboardingPageData data, {required bool isDesktop}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: isDesktop ? 340 : 250,
        borderRadius: 24,
        blur: 20,
        border: 1.5,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            data.accentColor.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "MODULE ACTIVE",
                  style: TextStyle(
                    color: data.accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom buttons, pagination dots
  Widget _buildFooterControls(int currentIndex, OnboardingPageData pageData) {
    final isLastPage = currentIndex == OnboardingAssets.pages.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Navigation buttons & dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button or spacing
            if (currentIndex > 0)
              IconButton(
                onPressed: () => _handleBack(currentIndex),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white60, size: 20),
                tooltip: 'Previous Step',
              )
            else
              const SizedBox(width: 48),

            // Indicator Dots
            Row(
              children: List.generate(
                OnboardingAssets.pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == currentIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: index == currentIndex
                        ? pageData.accentColor
                        : Colors.white24,
                  ),
                ),
              ),
            ),

            // Next button or spacing
            IconButton(
              onPressed: () => _handleNext(currentIndex),
              icon: Icon(
                isLastPage ? Icons.done : Icons.arrow_forward_ios,
                color: pageData.accentColor,
                size: 20,
              ),
              tooltip: isLastPage ? 'Complete' : 'Next Step',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Core CTA button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 54,
          child: isLastPage
              ? GlassmorphicContainer(
                  width: double.infinity,
                  height: 54,
                  borderRadius: 16,
                  blur: 15,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    colors: [
                      PremiumTheme.neonCyan.withValues(alpha: 0.3),
                      PremiumTheme.neonCyan.withValues(alpha: 0.1),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      PremiumTheme.neonCyan,
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: InkWell(
                    onTap: _finishOnboarding,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Text(
                        'ENTER THE FUTURE OF SMART CITIES',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                )
              : OutlinedButton(
                  onPressed: () => _handleNext(currentIndex),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: pageData.accentColor.withValues(alpha: 0.4), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'PROCEED TO NEXT MODULE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Custom Painter to draw a clean cyberpunk grid pattern
class _CyberGridPainter extends CustomPainter {
  final Color gridColor;

  _CyberGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const double step = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor;
  }
}
