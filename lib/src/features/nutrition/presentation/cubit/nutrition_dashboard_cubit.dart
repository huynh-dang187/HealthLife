import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/enums/bloc_status.dart';
import '../../data/model/food_model.dart';
import '../../data/model/meal_log_model.dart';
import '../../data/repositories/nutrition_repository.dart';
import 'nutrition_dashboard_state.dart';

class NutritionDashboardCubit extends Cubit<NutritionDashboardState> {
  NutritionDashboardCubit(this._repository) : super(const NutritionDashboardState());

  final NutritionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final targets = await _repository.fetchDailyTargets();
      final range = _rangeFor(state.period, DateTime.now());
      final logs = await _repository.getMealLogsInRange(range.start, range.end);
      final totals = _sumLevels(logs);

      emit(state.copyWith(
        status: BlocStatus.success,
        targets: targets,
        consumed: totals,
        logs: logs,
        error: null,
      ));
    } catch (e, st) {
      debugPrint('NutritionDashboard load failed: $e\n$st');
      emit(state.copyWith(status: BlocStatus.failure, error: e.toString()));
    }
  }

  Future<void> reload() => load();

  void changePeriod(NutritionPeriod period) {
    if (period == state.period) return;
    emit(state.copyWith(period: period, status: BlocStatus.loading));
    load();
  }

  Future<void> deleteLog(MealLogModel log) async {
    try {
      await _repository.deleteMealLog(log.id);
    } catch (_) {}

    final logs = List<MealLogModel>.from(state.logs)..removeWhere(
      (l) => l.id == log.id,
    );
    emit(state.copyWith(logs: logs, consumed: _sumLevels(logs)));
  }

  static FoodNutrients _sumLevels(List<MealLogModel> logs) {
    var total = const FoodNutrients();
    for (final log in logs) {
      total = total +
          FoodNutrients(
            calo: log.calo,
            protein: log.protein,
            fat: log.fat,
            carb: log.carb,
            fiber: log.fiber,
          );
    }
    return total.rounded();
  }

  /// Khoảng thời gian hiển thị theo period, tính đến thời điểm hiện tại.
  static ({DateTime start, DateTime end}) _rangeFor(
    NutritionPeriod period,
    DateTime now,
  ) {
    final start = switch (period) {
      NutritionPeriod.day => DateTime(now.year, now.month, now.day),
      NutritionPeriod.week => DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - DateTime.monday),
      ),
      NutritionPeriod.month => DateTime(now.year, now.month, 1),
      NutritionPeriod.year => DateTime(now.year, 1, 1),
    };
    return (start: start, end: now);
  }
}