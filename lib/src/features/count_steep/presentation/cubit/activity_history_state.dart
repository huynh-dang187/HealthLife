import 'package:equatable/equatable.dart';

import 'package:healthlife/src/features/count_steep/data/models/activity_stat_item.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';
import 'package:healthlife/src/features/count_steep/domains/enums/activity_period.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

/// Trạng thái màn hình lịch sử bước chân.
class ActivityHistoryState extends Equatable {
  const ActivityHistoryState({
    this.status = BlocStatus.initial,
    this.period = ActivityPeriod.week,
    this.anchor,
    this.rangeTitle = '',
    this.goal = 6000,
    this.chartData = const <StepChartData>[],
    this.stats = const <ActivityStatItem>[],
    this.error,
  });

  final BlocStatus status;

  /// Khoảng đang chọn: Tuần / Tháng / Năm.
  final ActivityPeriod period;

  /// Ngày bắt đầu khoảng đang xem: thứ 2 của tuần, mùng 1 của tháng,
  /// 1/1 của năm. Căn cứ để xử lý nút "<" ">".
  final DateTime? anchor;

  /// Tiêu đề giữa nút "<" ">" (vd: '11 thg 8 - 17 thg 8').
  final String rangeTitle;

  /// Mục tiêu hiện tại để vẽ đường mục tiêu trên biểu đồ.
  final int goal;

  /// Data biểu đồ theo period đang chọn.
  final List<StepChartData> chartData;

  /// 4 card thống kê tính từ chính [chartData].
  final List<ActivityStatItem> stats;

  final String? error;

  bool get isLoading =>
      status == BlocStatus.initial || status == BlocStatus.loading;

  ActivityHistoryState copyWith({
    BlocStatus? status,
    ActivityPeriod? period,
    DateTime? anchor,
    String? rangeTitle,
    int? goal,
    List<StepChartData>? chartData,
    List<ActivityStatItem>? stats,
    String? error,
  }) {
    return ActivityHistoryState(
      status: status ?? this.status,
      period: period ?? this.period,
      anchor: anchor ?? this.anchor,
      rangeTitle: rangeTitle ?? this.rangeTitle,
      goal: goal ?? this.goal,
      chartData: chartData ?? this.chartData,
      stats: stats ?? this.stats,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    anchor,
    rangeTitle,
    goal,
    chartData,
    stats,
    error,
  ];
}