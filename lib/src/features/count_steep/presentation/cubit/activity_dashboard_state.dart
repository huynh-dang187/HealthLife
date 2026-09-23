import 'package:equatable/equatable.dart';

import 'package:healthlife/src/shared/enums/bloc_status.dart';

/// Trạng thái dashboard đếm bước chân.
class ActivityDashboardState extends Equatable {
  const ActivityDashboardState({
    this.status = BlocStatus.initial,
    this.todaySteps = 0,
    this.stepGoal = 6000,
    this.streak = 0,
    this.error,
  });

  final BlocStatus status;

  /// Số bước hôm nay (từ sensor, sau khi trừ baseline).
  final int todaySteps;

  /// Mục tiêu bước từ `users/{uid}.stepGoal` (mặc định 6000).
  final int stepGoal;

  /// Chuỗi ngày liên tiếp đạt goal gần nhất.
  final int streak;

  final String? error;

  ActivityDashboardState copyWith({
    BlocStatus? status,
    int? todaySteps,
    int? stepGoal,
    int? streak,
    String? error,
  }) {
    return ActivityDashboardState(
      status: status ?? this.status,
      todaySteps: todaySteps ?? this.todaySteps,
      stepGoal: stepGoal ?? this.stepGoal,
      streak: streak ?? this.streak,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    todaySteps,
    stepGoal,
    streak,
    error,
  ];
}