import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../domains/enums/activity_tab.dart';
import '../widgets/dashboard/activity_tab_switch.dart';
import '../widgets/dashboard/overview_tab.dart';

/// Màn hình tổng quan đếm bước chân (UI + mock data).
class ActivityDashboardPage extends StatelessWidget {
  const ActivityDashboardPage({super.key});

  static const _mockStreak = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppAppBar(title: 'Thiết bị đo bước chân'),
          ActivityTabSwitch(
            selected: ActivityTab.overview,
            onChanged: (tab) {
              if (tab == ActivityTab.history) {
                context.push(RouteNames.activity_history);
              }
            },
          ),
          Expanded(child: OverviewTab(streak: _mockStreak)),
        ],
      ),
    );
  }
}