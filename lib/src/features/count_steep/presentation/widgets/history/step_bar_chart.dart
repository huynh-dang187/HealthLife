import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../data/models/step_chart_data.dart';

/// Biểu đồ cột bước chân (fl_chart):
/// - Trục Y mốc 0/2k/4k/6k/8k/10k, đường kẻ ngang chấm chấm ở mức mục tiêu
/// - Cột coral đậm khi đạt mục tiêu, cột nhạt viền coral khi chưa đạt
/// - Trục X nhãn theo từng cột (tự ẩn bớt nhãn nếu quá nhiều cột)
class StepBarChart extends StatelessWidget {
  const StepBarChart({
    super.key,
    required this.data,
    required this.goalLine,
    this.maxYInK = 10,
    this.height = 170,
  });

  final List<StepChartData> data;

  /// Mức mục tiêu tham chiếu (đơn vị bước) để vẽ đường chấm chấm.
  final int goalLine;

  /// Trục Y tối đa (đơn vị nghìn bước).
  final double maxYInK;

  final double height;

  static const _tickInterval = 2.0;
  static const _k = 1000.0;

  double _toY(int steps) => steps / _k;

  /// Tự ẩn bớt nhãn X khi danh sách quá dài (chỉ hiện ~6 mốc).
  int get _labelStep => data.length > 12 ? (data.length / 6).ceil() : 1;

  double get _barWidth {
    final n = data.length;
    if (n <= 7) return 22;
    if (n <= 12) return 14;
    return math.max(4.0, 300 / n);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              right: 4,
              left: 4,
              bottom: 4,
            ),
            child: BarChart(_chartData()),
          ),
        ),
        10.gap,
        _Legend(),
      ],
    );
  }

  BarChartData _chartData() {
    return BarChartData(
      minY: 0,
      maxY: maxYInK,
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _tickInterval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: UIColors.separate,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            interval: _tickInterval,
            getTitlesWidget: (value, meta) {
              if (value < 0) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                space: 6,
                child: AppText.regular(
                  value == 0 ? '0' : '${value.round()}k',
                  fontSize: 10,
                  color: UIColors.textBody,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) {
                return const SizedBox.shrink();
              }
              if (_labelStep > 1 && index % _labelStep != 0) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                space: 6,
                child: AppText.regular(
                  data[index].label,
                  fontSize: 9,
                  color: UIColors.textBody,
                ),
              );
            },
          ),
        ),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: _toY(goalLine),
            color: UIColors.coral,
            strokeWidth: 1.2,
            dashArray: [6, 4],
          ),
        ],
      ),
      barGroups: [
        for (var i = 0; i < data.length; i++)
          BarChartGroupData(
            x: i,
            barsSpace: i == 0 ? 4 : 6,
            barRods: [
              BarChartRodData(
                toY: _toY(data[i].steps),
                width: _barWidth,
                color: data[i].goalReached
                    ? UIColors.coral
                    : UIColors.pinkLight,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                borderSide: data[i].goalReached
                    ? BorderSide.none
                    : const BorderSide(color: UIColors.coral, width: 1.2),
              ),
            ],
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(color: UIColors.coral, borderColor: null),
        6.gap,
        AppText.regular(
          'Đã đạt được',
          fontSize: 11,
          color: UIColors.textBody,
        ),
        16.gap,
        _dot(color: UIColors.pinkLight, borderColor: UIColors.coral),
        6.gap,
        AppText.regular(
          'Chưa đạt được',
          fontSize: 11,
          color: UIColors.textBody,
        ),
      ],
    );
  }

  Widget _dot({required Color color, Color? borderColor}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.2)
            : null,
      ),
    );
  }
}