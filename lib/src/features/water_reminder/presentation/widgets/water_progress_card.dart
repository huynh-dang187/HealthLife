import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';

class WaterProgressCard extends StatelessWidget {
  final int currentIntake;
  final int dailyGoal;
  final double progress;
  final bool isGoalReached;

  const WaterProgressCard({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
    required this.progress,
    required this.isGoalReached,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = dailyGoal - currentIntake;
    final percentageText = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoalReached
              ? [const Color(0xFF00B4DB), const Color(0xFF0083B0)]
              : [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2193b0).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.medium(
                    'Lượng nước hôm nay',
                    color: UIColors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  6.gap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AppText.bold(
                        '$currentIntake',
                        color: UIColors.white,
                        fontSize: 36,
                      ),
                      AppText.semiBold(
                        ' / $dailyGoal ml',
                        color: UIColors.white.withValues(alpha: 0.9),
                        fontSize: 18,
                      ),
                    ],
                  ),
                ],
              ),
              // Vòng tiến độ hình tròn
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: UIColors.white.withValues(alpha: 0.24),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          UIColors.white,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: UIColors.white,
                          size: 20,
                        ),
                        AppText.bold(
                          '$percentageText%',
                          color: UIColors.white,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.gap,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: UIColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGoalReached ? Icons.stars : Icons.info_outline,
                  color: UIColors.white,
                  size: 18,
                ),
                8.gap,
                Expanded(
                  child: AppText.semiBold(
                    isGoalReached
                        ? 'Tuyệt vời! Bạn đã hoàn thành mục tiêu 🎉'
                        : 'Còn thiếu $remaining ml nữa để đạt mục tiêu',
                    color: UIColors.white,
                    fontSize: 13,
                    maxLines: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
