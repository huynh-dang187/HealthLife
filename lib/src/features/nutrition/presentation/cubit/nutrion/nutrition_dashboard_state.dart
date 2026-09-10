import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/bloc_status.dart';
import '../../../data/model/daily_target_model.dart';
import '../../../data/model/food_model.dart';
import '../../../data/model/meal_log_model.dart';

enum NutritionPeriod { day, week, month, year }

extension NutritionPeriodLabel on NutritionPeriod {
  String get vn => switch (this) {
    NutritionPeriod.day => 'Ngày',
    NutritionPeriod.week => 'Tuần',
    NutritionPeriod.month => 'Tháng',
    NutritionPeriod.year => 'Năm',
  };
}

class NutritionDashboardState extends Equatable {
  const NutritionDashboardState({
    this.status = BlocStatus.initial,
    this.period = NutritionPeriod.day,
    this.targets = const DailyTargetModel.defaults(),
    this.consumed = const FoodNutrients(),
    this.logs = const [],
    this.error,
  });

  final BlocStatus status;
  final NutritionPeriod period;

  /// Mục tiêu 1 ngày gốc (chưa scale theo số ngày của period).
  final DailyTargetModel targets;

  /// Tổng đã ăn trong period.
  final FoodNutrients consumed;

  final List<MealLogModel> logs;
  final String? error;

  /// Mục tiêu đã scale theo số ngày của period (NGÀY = targets, TUẦN = ×7...)
  DailyTargetModel get scaledTargets {
    final days = _scaleDays(period);
    return DailyTargetModel.fromCalories(targets.calo * days);
  }

  double get consumedCaloPercent {
    final goal = scaledTargets.calo;
    if (goal <= 0) return 0;
    return (consumed.calo / goal * 100).clamp(0, 999);
  }

  double get consumedProteinPercent {
    final goal = scaledTargets.protein;
    if (goal <= 0) return 0;
    return (consumed.protein / goal * 100).clamp(0, 999);
  }

  double get consumedFatPercent {
    final goal = scaledTargets.fat;
    if (goal <= 0) return 0;
    return (consumed.fat / goal * 100).clamp(0, 999);
  }

  double get consumedCarbPercent {
    final goal = scaledTargets.carb;
    if (goal <= 0) return 0;
    return (consumed.carb / goal * 100).clamp(0, 999);
  }

  double get consumedFiberPercent {
    final goal = scaledTargets.fiber;
    if (goal <= 0) return 0;
    return (consumed.fiber / goal * 100).clamp(0, 999);
  }

  static int _scaleDays(NutritionPeriod period) => switch (period) {
    NutritionPeriod.day => 1,
    NutritionPeriod.week => 7,
    NutritionPeriod.month => 30,
    NutritionPeriod.year => 365,
  };

  NutritionDashboardState copyWith({
    BlocStatus? status,
    NutritionPeriod? period,
    DailyTargetModel? targets,
    FoodNutrients? consumed,
    List<MealLogModel>? logs,
    String? error,
  }) {
    return NutritionDashboardState(
      status: status ?? this.status,
      period: period ?? this.period,
      targets: targets ?? this.targets,
      consumed: consumed ?? this.consumed,
      logs: logs ?? this.logs,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    targets,
    consumed,
    logs,
    error,
  ];
}