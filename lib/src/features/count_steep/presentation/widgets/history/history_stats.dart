import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/count_steep/data/models/activity_stat_item.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';
import 'package:healthlife/src/features/count_steep/domains/enums/activity_period.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_state.dart';

/// Ngày rút gọn theo locale (vd: '11 thg 8' / 'Aug 11').
String shortDate(BuildContext context, DateTime d) {
  final lang = context.locale.languageCode;
  return DateFormat(lang == 'en' ? 'MMM d' : 'd MMM', lang).format(d);
}

/// Tháng rút gọn theo locale (vd: 'thg 8' / 'Aug').
String shortMonth(BuildContext context, DateTime d) {
  final lang = context.locale.languageCode;
  return DateFormat('MMM', lang).format(d);
}

String rangeTitle(BuildContext context, ActivityHistoryState state) {
  final anchor = state.anchor;
  if (anchor == null) return '';
  return switch (state.period) {
    ActivityPeriod.week =>
      '${shortDate(context, anchor)} - '
          '${shortDate(context, anchor.add(const Duration(days: 6)))}',
    ActivityPeriod.month => '${shortMonth(context, anchor)} ${anchor.year}',
    ActivityPeriod.year => '${anchor.year}',
  };
}

/// Dựng danh sách thống kê (tính tại UI để có locale + context.tr).
List<ActivityStatItem> buildHistoryStats(
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
          ? shortDate(context, dateOf(streak.start))
          : '${shortDate(context, dateOf(streak.start))} - '
                '${shortDate(context, dateOf(streak.end))}';

  return [
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_best_day),
      value: _stepsValue(context, data[best].steps),
      subtitle: shortDate(context, dateOf(best)),
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_rest_day),
      value: _stepsValue(context, data[worst].steps),
      subtitle: shortDate(context, dateOf(worst)),
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
          ? shortMonth(context, monthOf(streak.start))
          : '${shortMonth(context, monthOf(streak.start))} - '
                '${shortMonth(context, monthOf(streak.end))}';

  return [
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_best_month),
      value: _stepsValue(context, data[best].steps),
      subtitle: shortMonth(context, monthOf(best)),
    ),
    ActivityStatItem(
      label: context.tr(LocaleKeys.count_steep_stat_rest_month),
      value: _stepsValue(context, data[worst].steps),
      subtitle: shortMonth(context, monthOf(worst)),
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

({int length, int start, int end}) _longestStreak(List<StepChartData> data) {
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