import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class StepProgressRing extends StatelessWidget {
  const StepProgressRing({
    super.key,
    required this.currentSteps,
    required this.goalSteps,
    this.strokeWidth = 14,
    this.onEditGoal,
  });

  final int currentSteps;
  final int goalSteps;
  final double strokeWidth;
  final VoidCallback? onEditGoal;

  @override
  Widget build(BuildContext context) {
    final progress = goalSteps <= 0
        ? 0.0
        : (currentSteps / goalSteps).clamp(0.0, 1.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 0.0;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;
        final side = _pickSide(width, height);

        return SizedBox(
          width: side,
          height: side,
          child: CustomPaint(
            painter: _StepRingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 16,
                        color: UIColors.pink.withValues(alpha: 0.9),
                      ),
                      6.gap,
                    ],
                  ),
                  6.gap,
                  AppText.bold(
                    currentSteps.vnFormat,
                    fontSize: 34,
                    color: UIColors.text,
                  ),
                  2.gap,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.regular(
                        '/${goalSteps.vnFormat} bước',
                        fontSize: 13,
                        color: UIColors.textBody,
                      ),
                      4.gap,
                      if (onEditGoal != null)
                        Tooltip(
                          message: 'Đặt mục tiêu bước',
                          child: GestureDetector(
                            onTap: onEditGoal,
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                Icons.mode_edit_outline,
                                size: 14,
                                color: UIColors.pink,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static double _pickSide(double width, double height) {
    if (height <= 0) return width > 0 ? width : 200.0;
    if (width <= 0) return height;
    return width < height ? width : height;
  }
}

class _StepRingPainter extends CustomPainter {
  const _StepRingPainter({required this.progress, required this.strokeWidth});

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = UIColors.black;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [
        UIColors.error,
        UIColors.error,
      ],
      stops: const [0.0, 1.0],
    ).createShader(rect);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    final angle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, angle, false, arc);
  }

  @override
  bool shouldRepaint(covariant _StepRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth;
}
