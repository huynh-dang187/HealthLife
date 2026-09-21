import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_cubit.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../domains/enums/activity_period.dart';
import '../../domains/enums/activity_tab.dart';
import '../widgets/dashboard/activity_tab_switch.dart';
import '../widgets/history/activity_stat_card.dart';
import '../widgets/history/step_bar_chart.dart';

/// Màn hình lịch sử bước chân: biểu đồ cột + 4 card thống kê (data thật).
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

  void _goOverview(BuildContext context) {
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
            onBack: () => _goOverview(context),
          ),
          ActivityTabSwitch(
            selected: ActivityTab.history,
            onChanged: (tab) {
              if (tab == ActivityTab.overview) _goOverview(context);
            },
          ),
          Expanded(
            child: BlocBuilder<ActivityHistoryCubit, ActivityHistoryState>(
              builder: (context, state) {
                final cubit = context.read<ActivityHistoryCubit>();
                final rangeLabel = state.rangeTitle.isNotEmpty
                    ? state.rangeTitle
                    : state.period.rangeLabel;

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
                          state.stats.isNotEmpty)
                        ActivityStatsGrid(items: state.stats),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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