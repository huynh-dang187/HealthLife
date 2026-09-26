import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_cubit.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_history_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import '../../domains/enums/activity_tab.dart';
import '../widgets/activity_page_scaffold.dart';
import '../widgets/history/activity_stat_card.dart';
import '../widgets/history/history_chart_card.dart';
import '../widgets/history/history_stats.dart';
import '../widgets/history/period_nav_row.dart';
import '../widgets/history/period_tabs.dart';

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
          final rangeLabel = rangeTitle(context, state);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PeriodNavRow(
                  rangeLabel: rangeLabel,
                  onPrev: cubit.previous,
                  onNext: cubit.next,
                ),
                PeriodTabs(
                  selected: state.period,
                  onChanged: cubit.selectPeriod,
                ),
                16.gap,
                HistoryChartCard(
                  isLoading: state.isLoading,
                  chartData: state.chartData,
                  goal: state.goal,
                ),
                16.gap,
                if (state.status == BlocStatus.success &&
                    state.chartData.isNotEmpty)
                  ActivityStatsGrid(items: buildHistoryStats(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }
}