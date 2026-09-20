import 'package:flutter/material.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';

import '../../domains/enums/activity_tab.dart';
import '../widgets/dashboard/activity_tab_switch.dart';
import '../widgets/dashboard/overview_tab.dart';
import '../widgets/history/history_tab.dart';

/// Màn hình tổng quan đếm bước chân (UI + mock data).
class ActivityDashboardPage extends StatefulWidget {
  const ActivityDashboardPage({super.key});

  @override
  State<ActivityDashboardPage> createState() => _ActivityDashboardPageState();
}

class _ActivityDashboardPageState extends State<ActivityDashboardPage> {
  static const _mockStreak = 5;

  ActivityTab _selectedTab = ActivityTab.overview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppAppBar(title: 'Thiết bị đo bước chân'),
          ActivityTabSwitch(
            selected: _selectedTab,
            onChanged: (tab) => setState(() => _selectedTab = tab),
          ),
          Expanded(
            child: switch (_selectedTab) {
              ActivityTab.overview => OverviewTab(streak: _mockStreak),
              ActivityTab.history => const HistoryTab(),
            },
          ),
        ],
      ),
    );
  }
}