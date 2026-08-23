import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/features/introduction/data/introduction_page_model.dart';

part 'introduction_state.dart';

class IntroductionCubit extends Cubit<IntroductionState> {
  IntroductionCubit()
    : super(IntroductionState(currentPage: 0, pages: _defaultPages));

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
}
