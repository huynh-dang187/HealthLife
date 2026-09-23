import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_cubit.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_state.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../domains/enums/activity_tab.dart';
import '../widgets/activity_page_scaffold.dart';
import '../widgets/dashboard/overview_tab.dart';

/// Màn hình tổng quan đếm bước chân (tổng quan + data thật từ cubit).
class ActivityDashboardPage extends StatelessWidget {
  const ActivityDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityDashboardCubit(
        ActivityRepository(),
        userCubit: context.read<UserCubit>(),
      )..start(),
      child: const _ActivityDashboardView(),
    );
  }
}

class _ActivityDashboardView extends StatelessWidget {
  const _ActivityDashboardView();

  @override
  Widget build(BuildContext context) {
    return ActivityPageScaffold(
      selected: ActivityTab.overview,
      onTabChanged: (tab) {
        if (tab == ActivityTab.history) {
          context.push(RouteNames.activity_history);
        }
      },
      child: BlocBuilder<ActivityDashboardCubit, ActivityDashboardState>(
        builder: (context, state) {
          return OverviewTab(
            streak: state.streak,
            currentSteps: state.todaySteps,
            goalSteps: state.stepGoal,
            status: state.status,
            error: state.error,
          );
        },
      ),
    );
  }
}
