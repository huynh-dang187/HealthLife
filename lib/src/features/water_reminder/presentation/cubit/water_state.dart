import 'package:equatable/equatable.dart';
import '../../data/models/water_log_model.dart';
import '../../data/models/water_settings_model.dart';

class WaterState extends Equatable {
  final bool isLoading;
  final int dailyGoal; // Mặc định 2000 ml
  final int currentIntake; // Tổng nước đã uống hôm nay (ml)
  final List<WaterLogModel> todayLogs;
  final WaterSettingsModel settings;
  final String? errorMessage;

  const WaterState({
    this.isLoading = false,
    this.dailyGoal = 2000,
    this.currentIntake = 0,
    this.todayLogs = const [],
    this.settings = const WaterSettingsModel(),
    this.errorMessage,
  });

  /// Phần trăm hoàn thành (0.0 đến 1.0)
  double get progressPercentage {
    if (dailyGoal <= 0) return 0.0;
    final ratio = currentIntake / dailyGoal;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  /// Lượng nước còn thiếu (ml)
  int get remainingIntake {
    final remaining = dailyGoal - currentIntake;
    return remaining < 0 ? 0 : remaining;
  }

  /// Đã đạt hoặc vượt mục tiêu ngày chưa
  bool get isGoalReached => currentIntake >= dailyGoal;

  WaterState copyWith({
    bool? isLoading,
    int? dailyGoal,
    int? currentIntake,
    List<WaterLogModel>? todayLogs,
    WaterSettingsModel? settings,
    String? errorMessage,
  }) {
    return WaterState(
      isLoading: isLoading ?? this.isLoading,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      currentIntake: currentIntake ?? this.currentIntake,
      todayLogs: todayLogs ?? this.todayLogs,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        dailyGoal,
        currentIntake,
        todayLogs,
        settings,
        errorMessage,
      ];
}
