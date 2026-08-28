import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/features/introduction/data/model/introduction_page_model.dart';
import 'package:healthlife/src/features/introduction/domain/enums/status.dart';

part 'introduction_state.dart';

class IntroductionCubit extends Cubit<IntroductionState> {
  IntroductionCubit()
    : super(IntroductionState(currentPage: 0, pages: _defaultPages));

  final pageController = PageController();

  static final _defaultPages = <IntroductionPageModel>[
    IntroductionPageModel(
      backgroundImage: Assets.png.icIntroduction1,
      description: LocaleKeys.introduction_medication_lookup,
    ),
    IntroductionPageModel(
      backgroundImage: Assets.png.icIntroduction2,
      description: LocaleKeys.introduction_health_tracking,
    ),
    IntroductionPageModel(
      backgroundImage: Assets.png.icIntroduction3,
      description: LocaleKeys.introduction_ai_health_companion,
    ),
  ];

  void onPageChanged(int index) {
    emit(state.copyWith(currentPage: index));
  }

  void nextPressed() {
    if (state.isLastPage) {
      emit(state.copyWith(status: IntroductionStatus.completed));
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: IntroductionStatus.initial));
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
