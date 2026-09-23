import 'package:equatable/equatable.dart';

import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';
import 'package:healthlife/src/features/count_steep/domains/enums/activity_period.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

/// Trạng thái màn hình lịch sử bước chân.
class ActivityHistoryState extends Equatable {
  const ActivityHistoryState({
    this.status = BlocStatus.initial,
    this.period = ActivityPeriod.week,
    this.anchor,
    this.goal = 6000,
    this.chartData = const <StepChartData>[],
    this.error,
  });

  final BlocStatus status;

  /// Khoảng đang chọn: Tuần / Tháng / Năm.
  final ActivityPeriod period;

  /// Ngày bắt đầu khoảng đang xem: thứ 2 của tuần, mùng 1 của tháng,
  /// 1/1 của năm. Căn cứ để xử lý nút "<" ">".
  final DateTime? anchor;

  /// Mục tiêu hiện tại để vẽ đường mục tiêu trên biểu đồ.
  final int goal;

  /// Data biểu đồ theo period đang chọn.
  final List<StepChartData> chartData;

  final String? error;

  bool get isLoading =>
      status == BlocStatus.initial || status == BlocStatus.loading;

  ActivityHistoryState copyWith({
    BlocStatus? status,
    ActivityPeriod? period,
    DateTime? anchor,
    int? goal,
    List<StepChartData>? chartData,
    String? error,
  }) {
    return ActivityHistoryState(
      status: status ?? this.status,
      period: period ?? this.period,
      anchor: anchor ?? this.anchor,
      goal: goal ?? this.goal,
      chartData: chartData ?? this.chartData,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    anchor,
    goal,
    chartData,
    error,
  ];
}