import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';

enum QuizOptionState {
  normal,
  selected,
  correct,
  wrong;

  Color get bg => switch (this) {
    QuizOptionState.normal => UIColors.lightGray,
    QuizOptionState.selected => UIColors.pink.withValues(alpha: 0.12),
    QuizOptionState.correct => UIColors.green.withValues(alpha: 0.12),
    QuizOptionState.wrong => UIColors.coral.withValues(alpha: 0.12),
  };

  Color get borderColor => switch (this) {
    QuizOptionState.normal => Colors.transparent,
    QuizOptionState.selected => UIColors.pink,
    QuizOptionState.correct => UIColors.green,
    QuizOptionState.wrong => UIColors.coral,
  };

  Color get textColor => switch (this) {
    QuizOptionState.normal => UIColors.textBody,
    QuizOptionState.selected => UIColors.pink,
    QuizOptionState.correct => UIColors.green,
    QuizOptionState.wrong => UIColors.coral,
  };

  Color? get checkColor => switch (this) {
    QuizOptionState.normal => null,
    QuizOptionState.selected => UIColors.pink,
    QuizOptionState.correct => UIColors.green,
    QuizOptionState.wrong => UIColors.coral,
  };
}