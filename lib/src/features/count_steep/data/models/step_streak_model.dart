import 'package:equatable/equatable.dart';

/// Thông tin chuỗi ngày liên tiếp đạt mục tiêu bước chân.
class StepStreakModel extends Equatable {
  const StepStreakModel({this.currentStreak = 0, this.bestStreak = 0});

  /// Số ngày liên tiếp gần nhất (tính từ hôm nay hoặc hôm qua) đạt goal.
  final int currentStreak;

  /// Số ngày liên tiếp cao nhất từng đạt được.
  final int bestStreak;

  @override
  List<Object?> get props => [currentStreak, bestStreak];
}