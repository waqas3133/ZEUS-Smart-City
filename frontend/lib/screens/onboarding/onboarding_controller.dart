import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final int currentPageIndex;
  final bool isCompleted;

  OnboardingState({
    required this.currentPageIndex,
    required this.isCompleted,
  });

  OnboardingState copyWith({
    int? currentPageIndex,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState(currentPageIndex: 0, isCompleted: false);
  }

  void setPage(int index) {
    state = state.copyWith(currentPageIndex: index);
  }

  void nextPage(int maxPages) {
    if (state.currentPageIndex < maxPages - 1) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex + 1);
    } else {
      completeOnboarding();
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex - 1);
    }
  }

  void completeOnboarding() {
    state = state.copyWith(isCompleted: true);
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(() {
  return OnboardingNotifier();
});
