import 'package:healthlife/src/shared/enums/bloc_status.dart';

import '../../data/models/quiz_question.dart';

final class QuizState {
  final BlocStatus status;
  final String? message;
  final List<QuizQuestion> questions;
  final List<int?> selectedIndices;

  const QuizState({
    this.status = BlocStatus.initial,
    this.message,
    this.questions = const [],
    this.selectedIndices = const [],
  });

  int? selectedFor(int index) => index >= 0 && index < selectedIndices.length
      ? selectedIndices[index]
      : null;

  bool isAnswered(int index) => selectedFor(index) != null;

  bool get allAnswered => questions.isNotEmpty && selectedIndices.every((s) => s != null);

  QuizState copyWith({
    BlocStatus? status,
    String? message,
    List<QuizQuestion>? questions,
    List<int?>? selectedIndices,
  }) {
    return QuizState(
      status: status ?? this.status,
      message: message ?? this.message,
      questions: questions ?? this.questions,
      selectedIndices: selectedIndices ?? this.selectedIndices,
    );
  }
}