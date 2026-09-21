import 'package:equatable/equatable.dart';

/// Bản ghi số bước 1 ngày, lưu tại
/// `users/{uid}/daily_steps/{yyyy-MM-dd}` trên Firestore.
class DailyStepModel extends Equatable {
  const DailyStepModel({
    required this.date,
    required this.steps,
    required this.goalReached,
  });

  /// Ngày dạng yyyy-MM-dd (múi giờ Asia/Ho_Chi_Minh).
  final String date;

  /// Tổng số bước trong ngày.
  final int steps;

  /// Đã đạt mục tiêu bước (users/{uid}.stepGoal) hay chưa.
  final bool goalReached;

  factory DailyStepModel.fromMap(String date, Map<String, dynamic> map) {
    return DailyStepModel(
      date: date,
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      goalReached: map['goalReached'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'goalReached': goalReached,
    };
  }

  DailyStepModel copyWith({int? steps, bool? goalReached}) {
    return DailyStepModel(
      date: date,
      steps: steps ?? this.steps,
      goalReached: goalReached ?? this.goalReached,
    );
  }

  @override
  List<Object?> get props => [date, steps, goalReached];
}