import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/count_steep/data/models/activity_stat_item.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/domains/enums/activity_period.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'activity_history_state.dart';

/// Quản lý lịch sử: period (Tuần/Tháng/Năm), mốc thời gian đang xem,
/// data biểu đồ + 4 card thống kê tính từ data thật.
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
      final stats = _buildStats(period, data, anchor);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            goal: goal,
            chartData: data,
            stats: stats,
            rangeTitle: _rangeTitle(period, anchor),
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

  String _rangeTitle(ActivityPeriod period, DateTime anchor) {
    return switch (period) {
      ActivityPeriod.week =>
        '${_dShort(anchor)} - ${_dShort(anchor.add(const Duration(days: 6)))}',
      ActivityPeriod.month => 'thg ${anchor.month} ${anchor.year}',
      ActivityPeriod.year => '${anchor.year}',
    };
  }

  // ----- Thống kê -----

  List<ActivityStatItem> _buildStats(
    ActivityPeriod period,
    List<StepChartData> data,
    DateTime anchor,
  ) {
    if (data.isEmpty) return const [];
    return switch (period) {
      ActivityPeriod.week => _dayStats(
        data,
        (i) => anchor.add(Duration(days: i)),
        'trong tuần',
        data.length,
      ),
      ActivityPeriod.month => _dayStats(
        data,
        (i) => DateTime(anchor.year, anchor.month, i + 1),
        'trong tháng',
        data.length,
      ),
      ActivityPeriod.year => _monthStats(data),
    };
  }

  List<ActivityStatItem> _dayStats(
    List<StepChartData> data,
    DateTime Function(int index) dateOf,
    String inScope,
    int totalDays,
  ) {
    final achieved = data.where((d) => d.goalReached).length;
    final best = _bestIndex(data, pickMax: true);
    final worst = _bestIndex(data, pickMax: false);
    final streak = _longestStreak(data);

    final streakRange = streak.length == 0
        ? 'chưa đạt ngày nào'
        : streak.start == streak.end
        ? _dShort(dateOf(streak.start))
        : '${_dShort(dateOf(streak.start))} - ${_dShort(dateOf(streak.end))}';

    return [
      ActivityStatItem(
        label: 'Ngày hoạt động nhất',
        value: '${data[best].steps.vnFormat} bước',
        subtitle: _dShort(dateOf(best)),
      ),
      ActivityStatItem(
        label: 'Ngày thư giãn nhất',
        value: '${data[worst].steps.vnFormat} bước',
        subtitle: _dShort(dateOf(worst)),
      ),
      ActivityStatItem(
        label: 'Chuỗi dài nhất',
        value: '${streak.length} ngày',
        subtitle: streakRange,
      ),
      ActivityStatItem(
        label: 'Đạt được mục tiêu',
        value: '$achieved/$totalDays ngày',
        subtitle: inScope,
      ),
    ];
  }

  List<ActivityStatItem> _monthStats(List<StepChartData> data) {
    final achieved = data.where((d) => d.goalReached).length;
    final best = _bestIndex(data, pickMax: true);
    final worst = _bestIndex(data, pickMax: false);
    final streak = _longestStreak(data);

    final streakRange = streak.length == 0
        ? 'chưa đạt tháng nào'
        : streak.start == streak.end
        ? 'thg ${streak.start + 1}'
        : 'thg ${streak.start + 1} - thg ${streak.end + 1}';

    return [
      ActivityStatItem(
        label: 'Tháng hoạt động nhất',
        value: '${data[best].steps.vnFormat} bước',
        subtitle: 'thg ${best + 1}',
      ),
      ActivityStatItem(
        label: 'Tháng thư giãn nhất',
        value: '${data[worst].steps.vnFormat} bước',
        subtitle: 'thg ${worst + 1}',
      ),
      ActivityStatItem(
        label: 'Chuỗi dài nhất',
        value: '${streak.length} tháng',
        subtitle: streakRange,
      ),
      ActivityStatItem(
        label: 'Đạt mục tiêu',
        value: '$achieved/12 tháng',
        subtitle: 'trong năm',
      ),
    ];
  }

  int _bestIndex(List<StepChartData> data, {required bool pickMax}) {
    var index = 0;
    for (var i = 1; i < data.length; i++) {
      if (pickMax
          ? data[i].steps > data[index].steps
          : data[i].steps < data[index].steps) {
        index = i;
      }
    }
    return index;
  }

  ({int length, int start, int end}) _longestStreak(
    List<StepChartData> data,
  ) {
    var length = 0, start = -1, end = -1;
    var run = 0, runStart = -1;
    for (var i = 0; i < data.length; i++) {
      if (data[i].goalReached) {
        if (run == 0) runStart = i;
        run++;
        if (run > length) {
          length = run;
          start = runStart;
          end = i;
        }
      } else {
        run = 0;
      }
    }
    return (length: length, start: start, end: end);
  }

  String _dShort(DateTime d) => '${d.day} thg ${d.month}';
}