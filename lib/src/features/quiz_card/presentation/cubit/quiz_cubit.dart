import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/quiz_card/data/repositories/quiz_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._repository) : super(const QuizState());

  final QuizRepository _repository;

  Future<void> loadToday() async {
    emit(state.copyWith(status: BlocStatus.loading, message: null));
    try {
      final questions = await _repository.getTodayQuestions();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          questions: questions,
          selectedIndices: List<int?>.filled(questions.length, null),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    final s = state;
    if (s.status != BlocStatus.success ||
        questionIndex < 0 ||
        questionIndex >= s.questions.length ||
        s.isAnswered(questionIndex)) {
      return;
    }
    final updated = List<int?>.from(s.selectedIndices)
      ..[questionIndex] = optionIndex;
    emit(s.copyWith(selectedIndices: updated));
  }
}