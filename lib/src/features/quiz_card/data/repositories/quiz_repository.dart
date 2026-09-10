import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz_question.dart';

class QuizRepository {
  static const _localAssetPath = 'assets/data/health_quiz.json';
  static const _questionsPerDay = 3;

  /// Chọn 3 câu hỏi cho hôm nay, bắt đầu từ mốc `dayOfYear * 3` rồi vòng quanh.
  Future<List<QuizQuestion>> getTodayQuestions() async {
    final raw = await rootBundle.loadString(_localAssetPath);
    final list = (jsonDecode(raw) as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    if (list.isEmpty) return const [];
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final start = (dayOfYear * _questionsPerDay) % list.length;
    return List.generate(
      _questionsPerDay,
      (i) => list[(start + i) % list.length],
    );
  }
}