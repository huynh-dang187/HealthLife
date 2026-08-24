// presentation/cubit/introduction_state.dart
part of 'introduction_cubit.dart';

class IntroductionState {
  final int currentPage;
  final List<IntroductionPageModel> pages;
  final IntroductionStatus status;

  const IntroductionState({
    required this.currentPage,
    required this.pages,
    this.status = IntroductionStatus.initial,
  });

  IntroductionState copyWith({int? currentPage, IntroductionStatus? status}) {
    return IntroductionState(
      currentPage: currentPage ?? this.currentPage,
      pages: pages,
      status: status ?? this.status,
    );
  }

  bool get isLastPage => currentPage == pages.length - 1;
}
