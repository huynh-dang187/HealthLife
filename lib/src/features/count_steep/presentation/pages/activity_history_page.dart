import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../domains/enums/activity_period.dart';
import '../../domains/enums/activity_tab.dart';
import '../../data/models/activity_stat_item.dart';
import '../../data/models/step_chart_data.dart';
import '../widgets/dashboard/activity_tab_switch.dart';
import '../widgets/history/activity_stat_card.dart';
import '../widgets/history/step_bar_chart.dart';

/// Màn hình lịch sử bước chân: biểu đồ cột + 4 card thống kê (mock data).
class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  static const _goal = 6000;

  ActivityPeriod _period = ActivityPeriod.week;

  List<StepChartData> get _chartData => switch (_period) {
    ActivityPeriod.week => _weekData,
    ActivityPeriod.month => _monthData,
    ActivityPeriod.year => _yearData,
  };

  List<ActivityStatItem> get _stats => switch (_period) {
    ActivityPeriod.week => _weekStats,
    ActivityPeriod.month => _monthStats,
    ActivityPeriod.year => _yearStats,
  };

  void _goOverview() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.activity_dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppAppBar(
            title: 'Thiết bị đo bước chân',
            onBack: _goOverview,
          ),
          ActivityTabSwitch(
            selected: ActivityTab.history,
            onChanged: (tab) {
              if (tab == ActivityTab.overview) _goOverview();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _periodNavRow(),
                  _PeriodTabs(
                    selected: _period,
                    onChanged: (p) => setState(() => _period = p),
                  ),
                  16.gap,
                  _chartCard(),
                  16.gap,
                  ActivityStatsGrid(items: _stats),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodNavRow() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_left),
          color: UIColors.text,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Center(
            child: AppText.semiBold(
              _period.rangeLabel,
              fontSize: 15,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_right),
          color: UIColors.text,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: StepBarChart(data: _chartData, goalLine: _goal),
    );
  }

  static const _weekData = [
    StepChartData(label: 'T2', steps: 3200, goalReached: false),
    StepChartData(label: 'T3', steps: 6400, goalReached: true),
    StepChartData(label: 'T4', steps: 7500, goalReached: true),
    StepChartData(label: 'T5', steps: 5100, goalReached: false),
    StepChartData(label: 'T6', steps: 9200, goalReached: true),
    StepChartData(label: 'T7', steps: 8800, goalReached: true),
    StepChartData(label: 'CN', steps: 4600, goalReached: false),
  ];

  static final _monthData = [
    for (var d = 1; d <= 30; d++)
      StepChartData(
        label: '$d',
        steps: _monthSteps(d),
        goalReached: _monthSteps(d) >= _goal,
      ),
  ];

  static int _monthSteps(int day) {
    final base = 4200 + (day * 320) % 2600;
    final weekend = day % 7 == 0 ? 2200 : 0;
    return base + weekend;
  }

  static const _yearData = [
    StepChartData(label: 'thg 1', steps: 5400, goalReached: false),
    StepChartData(label: 'thg 2', steps: 7200, goalReached: true),
    StepChartData(label: 'thg 3', steps: 6800, goalReached: true),
    StepChartData(label: 'thg 4', steps: 8100, goalReached: true),
    StepChartData(label: 'thg 5', steps: 5900, goalReached: false),
    StepChartData(label: 'thg 6', steps: 7600, goalReached: true),
    StepChartData(label: 'thg 7', steps: 8700, goalReached: true),
    StepChartData(label: 'thg 8', steps: 9400, goalReached: true),
    StepChartData(label: 'thg 9', steps: 5200, goalReached: false),
    StepChartData(label: 'thg 10', steps: 6400, goalReached: true),
    StepChartData(label: 'thg 11', steps: 7100, goalReached: true),
    StepChartData(label: 'thg 12', steps: 4950, goalReached: false),
  ];

  static const _weekStats = [
    ActivityStatItem(
      label: 'Ngày hoạt động nhất',
      value: '10.000 bước',
      subtitle: '13 thg 8',
    ),
    ActivityStatItem(
      label: 'Ngày thư giãn nhất',
      value: '1.200 bước',
      subtitle: '15 thg 8',
    ),
    ActivityStatItem(
      label: 'Chuỗi dài nhất',
      value: '5 ngày',
      subtitle: '11 - 15 thg 8',
    ),
    ActivityStatItem(
      label: 'Đạt được mục tiêu',
      value: '4/7 ngày',
      subtitle: 'trong tuần',
    ),
  ];

  static const _monthStats = [
    ActivityStatItem(
      label: 'Ngày hoạt động nhất',
      value: '10.000 bước',
      subtitle: '21 thg 8',
    ),
    ActivityStatItem(
      label: 'Ngày thư giãn nhất',
      value: '800 bước',
      subtitle: '2 thg 8',
    ),
    ActivityStatItem(
      label: 'Chuỗi dài nhất',
      value: '7 ngày',
      subtitle: '13 - 19 thg 8',
    ),
    ActivityStatItem(
      label: 'Đạt được mục tiêu',
      value: '18/30 ngày',
      subtitle: 'trong tháng',
    ),
  ];

  static const _yearStats = [
    ActivityStatItem(
      label: 'Ngày hoạt động nhất',
      value: '10.000 bước',
      subtitle: '8 thg 6',
    ),
    ActivityStatItem(
      label: 'Ngày thư giãn nhất',
      value: '1.000 bước',
      subtitle: '1 thg 1',
    ),
    ActivityStatItem(
      label: 'Chuỗi dài nhất',
      value: '12 ngày',
      subtitle: 'thg 9',
    ),
    ActivityStatItem(
      label: 'Đạt được mục tiêu',
      value: '215/365 ngày',
      subtitle: 'trong năm',
    ),
  ];
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onChanged});

  final ActivityPeriod selected;
  final ValueChanged<ActivityPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final period in ActivityPeriod.values)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(period),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.semiBold(
                  period.label,
                  fontSize: 14,
                  color: period == selected
                      ? UIColors.coral
                      : UIColors.textBody,
                ),
                6.gap,
                Container(
                  width: period == selected ? 28 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: UIColors.coral,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}