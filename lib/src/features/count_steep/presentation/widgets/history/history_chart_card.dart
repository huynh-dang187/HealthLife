import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/features/count_steep/data/models/step_chart_data.dart';

import 'step_bar_chart.dart';

/// Card chứa biểu đồ; khi đang tải thì hiện spinner.
class HistoryChartCard extends StatelessWidget {
  const HistoryChartCard({
    super.key,
    required this.isLoading,
    required this.chartData,
    required this.goal,
  });

  final bool isLoading;
  final List<StepChartData> chartData;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: isLoading
          ? const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          : StepBarChart(data: chartData, goalLine: goal),
    );
  }
}