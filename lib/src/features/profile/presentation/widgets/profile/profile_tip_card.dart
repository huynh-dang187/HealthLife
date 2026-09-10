import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/daily_tips/presentation/cubit/daily_tip_cubit.dart';

class ProfileTipCard extends StatelessWidget {
  const ProfileTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DailyTipCubit>().state;
    final emoji = state.displayEmoji;

    return Container(
      decoration: BoxDecoration(
        color: UIColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _DashedRoundedPainter(
          color: UIColors.pink.withValues(alpha: 0.5),
          radius: 20,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.semiBold(
                      'Mỗi ngày một lời khuyên',
                      fontSize: 14,
                      color: UIColors.pink,
                    ),
                    6.gap,
                    AppText.medium(
                      state.displayTip,
                      fontSize: 13,
                      color: UIColors.text,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              12.gap,
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: UIColors.pinkLight,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: emoji != null
                    ? Text(emoji, style: const TextStyle(fontSize: 20))
                    : Icon(
                        Icons.medical_services_outlined,
                        size: 20,
                        color: UIColors.pink,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedPainter extends CustomPainter {
  const _DashedRoundedPainter({
    required this.color,
    this.radius = 20,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.4;
    const dashSize = 7.0;
    const gapSize = 5.0;
    final rrectPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final metric = rrectPath.computeMetrics().first;
    final dashes = <Path>[];
    var distance = 0.0;
    while (distance < metric.length) {
      dashes.add(metric.extractPath(distance, distance + dashSize));
      distance += dashSize + gapSize;
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final dash in dashes) {
      canvas.drawPath(dash, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRoundedPainter oldDelegate) =>
      oldDelegate.color != color;
}
