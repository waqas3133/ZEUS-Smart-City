import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/router/app_router.dart';

class DemoPlaybookStep {
  final String title;
  final String description;
  final String route;
  final Duration duration;

  DemoPlaybookStep({
    required this.title,
    required this.description,
    required this.route,
    required this.duration,
  });
}

class DemoPlaybookState {
  final bool isPlaying;
  final int currentStepIndex;
  final bool isCollapsed;

  DemoPlaybookState({
    required this.isPlaying,
    required this.currentStepIndex,
    required this.isCollapsed,
  });

  DemoPlaybookState copyWith({
    bool? isPlaying,
    int? currentStepIndex,
    bool? isCollapsed,
  }) {
    return DemoPlaybookState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}

class DemoPlaybookNotifier extends Notifier<DemoPlaybookState> {
  Timer? _timer;
  int _secondsRemaining = 0;
  Timer? _tickTimer;

  @override
  DemoPlaybookState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _tickTimer?.cancel();
    });
    return DemoPlaybookState(
      isPlaying: false,
      currentStepIndex: -1,
      isCollapsed: false,
    );
  }

  int get secondsRemaining => _secondsRemaining;

  final List<DemoPlaybookStep> steps = [
    DemoPlaybookStep(
      title: "ZEUS Core Network",
      description: "Welcome to ZEUS Smart City Crisis Intelligence. Watch the multi-agent swarm orchestrate crisis responses in real time.",
      route: "/dashboard",
      duration: const Duration(seconds: 6),
    ),
    DemoPlaybookStep(
      title: "Hazard Radar Monitoring",
      description: "AI Weather Agent detects severe rainstorm fronts approaching. Geofenced emergency notifications are broadcasted immediately.",
      route: "/live-map",
      duration: const Duration(seconds: 9),
    ),
    DemoPlaybookStep(
      title: "Urdu AI Chatbot",
      description: "Citizens ask threat and safety questions in Urdu / Roman Urdu. AI Swarm provides immediate localized response details.",
      route: "/ai-chatbot",
      duration: const Duration(seconds: 11),
    ),
    DemoPlaybookStep(
      title: "Emergency Dispatch Swarm",
      description: "Primary expressway is flooded. Routing swarm calculates alternate bypass and simulates a dispatch run.",
      route: "/traffic-intelligence",
      duration: const Duration(seconds: 13),
    ),
    DemoPlaybookStep(
      title: "Citizen Edge Vision Reporting",
      description: "A citizen uploads a flood photo. Vision AI processes hazards, ranks indices, and logs reports to Firestore.",
      route: "/emergency-upload",
      duration: const Duration(seconds: 11),
    ),
    DemoPlaybookStep(
      title: "Admin Command Center",
      description: "Active crisis telemetry and response indicators update instantly on the master admin dashboard.",
      route: "/admin",
      duration: const Duration(seconds: 8),
    ),
  ];

  DemoPlaybookStep? get currentStep {
    final idx = state.currentStepIndex;
    if (idx >= 0 && idx < steps.length) {
      return steps[idx];
    }
    return null;
  }

  void toggleCollapse() {
    state = state.copyWith(isCollapsed: !state.isCollapsed);
  }

  void startAutoplay() {
    if (state.isPlaying) return;
    state = state.copyWith(isPlaying: true);
    if (state.currentStepIndex == -1 || state.currentStepIndex >= steps.length - 1) {
      jumpToStep(0);
    } else {
      _runStep(state.currentStepIndex);
    }
  }

  void pauseAutoplay() {
    _timer?.cancel();
    _tickTimer?.cancel();
    state = state.copyWith(isPlaying: false);
  }

  void nextStep() {
    if (state.currentStepIndex < steps.length - 1) {
      jumpToStep(state.currentStepIndex + 1);
    } else {
      resetPlaybook();
    }
  }

  void prevStep() {
    if (state.currentStepIndex > 0) {
      jumpToStep(state.currentStepIndex - 1);
    }
  }

  void resetPlaybook() {
    _timer?.cancel();
    _tickTimer?.cancel();
    state = DemoPlaybookState(
      isPlaying: false,
      currentStepIndex: -1,
      isCollapsed: false,
    );
    appRouter.go('/dashboard');
  }

  void jumpToStep(int index) {
    _timer?.cancel();
    _tickTimer?.cancel();
    
    if (index < 0 || index >= steps.length) return;

    state = state.copyWith(
      currentStepIndex: index,
    );

    final step = steps[index];
    appRouter.go(step.route);

    if (state.isPlaying) {
      _runStep(index);
    } else {
      _secondsRemaining = step.duration.inSeconds;
    }
  }

  void _runStep(int index) {
    final step = steps[index];
    _secondsRemaining = step.duration.inSeconds;

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        _secondsRemaining--;
      } else {
        _tickTimer?.cancel();
      }
    });

    _timer = Timer(step.duration, () {
      if (index < steps.length - 1) {
        jumpToStep(index + 1);
      } else {
        pauseAutoplay();
      }
    });
  }
}

final demoPlaybookProvider = NotifierProvider<DemoPlaybookNotifier, DemoPlaybookState>(DemoPlaybookNotifier.new);
