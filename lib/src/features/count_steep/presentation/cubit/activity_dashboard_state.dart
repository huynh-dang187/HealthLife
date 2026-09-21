import 'package:equatable/equatable.dart';

import 'package:healthlife/src/shared/enums/bloc_status.dart';

/// Trạng thái dashboard đếm bước chân.
class ActivityDashboardState extends Equatable {
  const ActivityDashboardState({
    this.status = BlocStatus.initial,
    this.permissionGranted = false,
    this.todaySteps = 0,
    this.stepGoal = 6000,
    this.streak = 0,
    this.bestStreak = 0,
    this.error,
  });

  final BlocStatus status;

  /// Đã được cấp quyền đọc cảm biến bước chân chưa.
  final bool permissionGranted;

  /// Số bước hôm nay (từ sensor, sau khi trừ baseline).
  final int todaySteps;

  /// Mục tiêu bước từ `users/{uid}.stepGoal` (mặc định 6000).
  final int stepGoal;

  /// Chuỗi ngày liên tiếp đạt goal gần nhất.
  final int streak;

  /// Chuỗi ngày dài nhất từng đạt goal.
  final int bestStreak;

  final String? error;

  bool get goalReached => stepGoal > 0 && todaySteps >= stepGoal;

  double get goalPercent {
    if (stepGoal <= 0) return 0;
    return (todaySteps / stepGoal * 100).clamp(0.0, 999.0).toDouble();
  }

  ActivityDashboardState copyWith({
    BlocStatus? status,
    bool? permissionGranted,
    int? todaySteps,
    int? stepGoal,
    int? streak,
    int? bestStreak,
    String? error,
  }) {
    return ActivityDashboardState(
      status: status ?? this.status,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      todaySteps: todaySteps ?? this.todaySteps,
      stepGoal: stepGoal ?? this.stepGoal,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    permissionGranted,
    todaySteps,
    stepGoal,
    streak,
    bestStreak,
    error,
  ];
}