import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/domains/enums/activity_period.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'activity_history_state.dart';

/// Quản lý lịch sử: period (Tuần/Tháng/Năm), mốc thời gian đang xem,
/// data biểu đồ (thống kê + tiêu đề khoảng được tính tại UI theo locale).
class ActivityHistoryCubit extends Cubit<ActivityHistoryState> {
  ActivityHistoryCubit(this._repository) : super(const ActivityHistoryState());

  final ActivityRepository _repository;

  /// Tải lần đầu với period mặc định Tuần (tuần hiện tại).
  Future<void> start() => selectPeriod(ActivityPeriod.week);

  /// Khoảng thời gian trước (nút "<") / sau (nút ">").
  Future<void> previous() => _shiftBy(-1);
  Future<void> next() => _shiftBy(1);

  Future<void> selectPeriod(ActivityPeriod period) async {
    final anchor = _periodStart(_repository.vnNow(), period);
    await _load(period, anchor);
  }

  Future<void> _shiftBy(int direction) async {
    final period = state.period;
    final anchor = state.anchor ?? _periodStart(_repository.vnNow(), period);
    var shifted = _shiftAnchor(anchor, period, direction);

    // Không cho xem tương lai: chặn ở kỳ hiện tại.
    final maxAnchor = _periodStart(_repository.vnNow(), period);
    if (shifted.isAfter(maxAnchor)) shifted = maxAnchor;
    if (shifted == anchor) return;

    await _load(period, shifted);
  }

  Future<void> _load(ActivityPeriod period, DateTime anchor) async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        period: period,
        anchor: anchor,
      ),
    );
    try {
      final data = await switch (period) {
        ActivityPeriod.week => _repository.getWeeklyData(anchor),
        ActivityPeriod.month => _repository.getMonthlyData(anchor),
        ActivityPeriod.year => _repository.getYearlyData(anchor.year),
      };
      final goal = await _repository.fetchStepGoal();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            goal: goal,
            chartData: data,
            error: null,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[HistoryCubit] load $period @$anchor failed: $e\n$st');
      if (!isClosed) {
        emit(state.copyWith(status: BlocStatus.failure, error: '$e'));
      }
    }
  }

  /// Mốc bắt đầu của kỳ hiện tại so với [now].
  DateTime _periodStart(DateTime now, ActivityPeriod period) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      ActivityPeriod.week => today.subtract(Duration(days: now.weekday - 1)),
      ActivityPeriod.month => DateTime(now.year, now.month, 1),
      ActivityPeriod.year => DateTime(now.year, 1, 1),
    };
  }

  /// Dịch mốc sang kỳ trước/sau đúng 1 đơn vị theo [period].
  DateTime _shiftAnchor(DateTime anchor, ActivityPeriod period, int delta) {
    return switch (period) {
      ActivityPeriod.week => anchor.add(Duration(days: 7 * delta)),
      ActivityPeriod.month => DateTime(anchor.year, anchor.month + delta, 1),
      ActivityPeriod.year => DateTime(anchor.year + delta, 1, 1),
    };
  }
}