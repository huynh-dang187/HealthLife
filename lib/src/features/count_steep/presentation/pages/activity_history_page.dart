import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/count_steep/data/models/activity_stat_item.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_cubit.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import '../../domains/enums/activity_period.dart';
import '../../domains/enums/activity_tab.dart';
import '../widgets/activity_page_scaffold.dart';
import '../widgets/history/activity_stat_card.dart';
import '../widgets/history/step_bar_chart.dart';

class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityHistoryCubit(ActivityRepository())..start(),
      child: const _ActivityHistoryView(),
    );
  }
}

class _ActivityHistoryView extends StatelessWidget {
  const _ActivityHistoryView();
  @override
  Widget build(BuildContext context) {
    return ActivityPageScaffold(
      centerTitle: true,
      onBack: () => context.pop(),
      selected: ActivityTab.history,
      onTabChanged: (tab) {
        if (tab == ActivityTab.overview) context.pop();
      },
      child: BlocBuilder<ActivityHistoryCubit, ActivityHistoryState>(
        builder: (context, state) {
          final cubit = context.read<ActivityHistoryCubit>();
          final rangeLabel = _rangeTitle(context, state);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PeriodNavRow(
                  rangeLabel: rangeLabel,
                  onPrev: cubit.previous,
                  onNext: cubit.next,
                ),
                _PeriodTabs(
                  selected: state.period,
                  onChanged: cubit.selectPeriod,
                ),
                16.gap,
                _chartCard(state),
                16.gap,
                if (state.status == BlocStatus.success &&
                    state.chartData.isNotEmpty)
                  ActivityStatsGrid(items: _buildStats(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chartCard(ActivityHistoryState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: state.isLoading
          ? const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          : StepBarChart(data: state.chartData, goalLine: state.goal),
    );
  }
}

/// Ngày rút gọn theo locale (vd: '11 thg 8' / 'Aug 11').
String _shortDate(BuildContext context, DateTime d) {
  final lang = context.locale.languageCode;
  return DateFormat(lang == 'en' ? 'MMM d' : 'd MMM', lang).format(d);
}

/// Tháng rút gọn theo locale (vd: 'thg 8' / 'Aug').
String _shortMonth(BuildContext context, DateTime d) {
  final lang = context.locale.languageCode;
  return DateFormat('MMM', lang).format(d);
}

String _rangeTitle(BuildContext context, ActivityHistoryState state) {
  final anchor = state.anchor;
  if (anchor == null) return '';
  return switch (state.period) {
    ActivityPeriod.week =>
      '${_shortDate(context, anchor)} - '
          '${_shortDate(context, anchor.add(const Duration(days: 6)))}',
    ActivityPeriod.month => '${_shortMonth(context, anchor)} ${anchor.year}',
    ActivityPeriod.year => '${anchor.year}',
  };
}

// ----- Thống kê (tính tại UI để có locale + context.tr) -----

List<ActivityStatItem> _buildStats(
  BuildContext context,
  ActivityHistoryState state,
) {
  final data = state.chartData;
  final anchor = state.anchor;
  if (data.isEmpty || anchor == null) return const [];
  return switch (state.period) {
    ActivityPeriod.week => _dayStats(
      context,
      data,
      (i) => anchor.add(Duration(days: i)),
      LocaleKeys.count_steep_stat_in_week,
      data.length,
    ),
    ActivityPeriod.month => _dayStats(
      context,
      data,
      (i) => DateTime(anchor.year, anchor.month, i + 1),
      LocaleKeys.count_steep_stat_in_month,
      data.length,
    ),
    ActivityPeriod.year => _monthStats(context, data),
  };
}

List<ActivityStatItem> _dayStats(
  BuildContext context,
  List<StepChartData> data,
  DateTime Function(int index) dateOf,
  String inScopeKey,
  int totalDays,
) {
  final achieved = data.where((d) => d.goalReached).length;
  final best = _bestIndex(data, pickMax: true);
  final worst = _bestIndex(data, pickMax: false);
  final streak = _longestStreak(data);

  final streakRange = streak.length == 0
      ? context.tr(LocaleKeys.count_steep_stat_no_day)
      : streak.start == streak.end
      ? _shortDate(context, dateOf(streak.start))
      : '${_shortDate(context, dateOf(streak.start))} - '
            '${_shortDate(context, dateOf(streak.end))}';

  return [
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_best_day),
      value: _stepsValue(context, data[best].steps),
      subtitle: _shortDate(context, dateOf(best)),
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_rest_day),
      value: _stepsValue(context, data[worst].steps),
      subtitle: _shortDate(context, dateOf(worst)),
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_longest_streak),
      value: context.tr(
        LocaleKeys.count_steep_stat_streak_days,
        namedArgs: {'count': '${streak.length}'},
      ),
      subtitle: streakRange,
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_goal_reached),
      value: context.tr(
        LocaleKeys.count_steep_stat_days_count,
        namedArgs: {'achieved': '$achieved', 'total': '$totalDays'},
      ),
      subtitle: context.tr(inScopeKey),
    ),
  ];
}

List<ActivityStatItem> _monthStats(
  BuildContext context,
  List<StepChartData> data,
) {
  final achieved = data.where((d) => d.goalReached).length;
  final best = _bestIndex(data, pickMax: true);
  final worst = _bestIndex(data, pickMax: false);
  final streak = _longestStreak(data);

  DateTime monthOf(int index) => DateTime(2024, index + 1, 1);
  final streakRange = streak.length == 0
      ? context.tr(LocaleKeys.count_steep_stat_no_month)
      : streak.start == streak.end
      ? _shortMonth(context, monthOf(streak.start))
      : '${_shortMonth(context, monthOf(streak.start))} - '
            '${_shortMonth(context, monthOf(streak.end))}';

  return [
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_best_month),
      value: _stepsValue(context, data[best].steps),
      subtitle: _shortMonth(context, monthOf(best)),
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_rest_month),
      value: _stepsValue(context, data[worst].steps),
      subtitle: _shortMonth(context, monthOf(worst)),
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_longest_streak),
      value: context.tr(
        LocaleKeys.count_steep_stat_streak_months,
        namedArgs: {'count': '${streak.length}'},
      ),
      subtitle: streakRange,
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_goal_reached),
      value: context.tr(
        LocaleKeys.count_steep_stat_months_count,
        namedArgs: {'achieved': '$achieved'},
      ),
      subtitle: context.tr(LocaleKeys.count_steep_stat_in_year),
    ),
  ];
}

String _stepsValue(BuildContext context, int steps) => context.tr(
  LocaleKeys.count_steep_steps_count,
  namedArgs: {'count': steps.vnFormat},
);

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

class _PeriodNavRow extends StatelessWidget {
  const _PeriodNavRow({
    required this.rangeLabel,
    required this.onPrev,
    required this.onNext,
  });

  final String rangeLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          color: UIColors.text,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Center(
            child: AppText.semiBold(
              rangeLabel,
              fontSize: 15,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: UIColors.text,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
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
                  context.tr(period.labelKey),
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
