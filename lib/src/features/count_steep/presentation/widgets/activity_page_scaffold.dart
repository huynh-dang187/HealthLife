import 'package:flutter/material.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';

import '../../domains/enums/activity_tab.dart';
import 'dashboard/activity_tab_switch.dart';

/// Khung chung cho các màn hình tính năng bước chân:
/// AppBar "Thiết bị đo bước chân" + tab Tổng quan/Lịch sử + nội dung.
class ActivityPageScaffold extends StatelessWidget {
  const ActivityPageScaffold({
    super.key,
    required this.selected,
    required this.onTabChanged,
    required this.child,
    this.onBack,
    this.centerTitle = true,
  });

  final ActivityTab selected;
  final ValueChanged<ActivityTab> onTabChanged;
  final Widget child;
  final VoidCallback? onBack;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppAppBar(
            title: 'Thiết bị đo bước chân',
            onBack: onBack,
            centerTitle: centerTitle,
          ),
          ActivityTabSwitch(selected: selected, onChanged: onTabChanged),
          Expanded(child: child),
        ],
      ),
    );
  }
}