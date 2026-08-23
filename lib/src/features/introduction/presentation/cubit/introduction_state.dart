// presentation/cubit/introduction_state.dart
part of 'introduction_cubit.dart';

class IntroductionState {
  final int currentPage;
  final List<IntroductionPageModel> pages;

  const IntroductionState({required this.currentPage, required this.pages});

  IntroductionState copyWith({int? currentPage}) {
    return IntroductionState(
      currentPage: currentPage ?? this.currentPage,
      pages: pages,
    );
  }

  bool get isLastPage => currentPage == pages.length - 1;
}
