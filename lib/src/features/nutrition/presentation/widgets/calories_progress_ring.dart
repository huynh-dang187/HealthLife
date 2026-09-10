import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Vòng tròn progress "Đã nạp vào" (kcal) so với mục tiêu.
class CaloriesProgressRing extends StatelessWidget {
  const CaloriesProgressRing({
    super.key,
    required this.calories,
    required this.progress,
    this.color = UIColors.pink,
    this.trackColor = UIColors.pinkLight,
    this.size = 128,
  });

  /// Số kcal đã nạp.
  final double calories;

  /// Tỉ lệ nạp (0 → 1, có thể > 1), arc sẽ clamp ở 1.
  final double progress;

  final Color color;
  final Color trackColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: clamped,
          color: color,
          trackColor: trackColor,
          strokeWidth: 12,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.medium(
                'Đã nạp vào',
                fontSize: 11,
                color: UIColors.textBody,
              ),
              2.gap,
              AppText.bold(
                _format(calories),
                fontSize: 26,
                color: UIColors.text,
              ),
              AppText.regular(
                'kcal',
                fontSize: 12,
                color: UIColors.textBody,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(double value) {
    final v = value.round();
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toString();
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    final angle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      angle,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}