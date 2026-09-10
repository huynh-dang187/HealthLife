class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;

  String get correctOption => options[correctIndex];

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    final correctIndex = json['correctIndex'] as int;
    if (correctIndex < 0 || correctIndex >= options.length) {
      throw const FormatException('correctIndex ngoài phạm vi options');
    }
    return QuizQuestion(
      question: json['question'] as String,
      options: options,
      correctIndex: correctIndex,
      explanation: (json['explanation'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Tổng quát',
    );
  }
}