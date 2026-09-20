import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../step_progress_ring.dart';
import '../streaks/streak_badge.dart';
import 'card/heart_rate_card.dart';
import 'stat_card.dart';
import 'card/water_goal_card.dart';

/// Nội dung tab "Tổng quan": ring, streak, thống kê và các card nhanh.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final ringSize = (context.screenWidth - 48) * 0.7;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: StreakBadge(streak: streak),
          ),
          20.gap,
          Center(
            child: SizedBox(
              width: ringSize,
              height: ringSize,
              child: const StepProgressRing(
                currentSteps: 3011,
                goalSteps: 6000,
              ),
            ),
          ),
          24.gap,
          Center(
            child: AppText.regular(
              'Bạn đã đạt được mục tiêu liên tiếp $streak ngày. Tiếp tục cố gắng nào!',
              fontSize: 13,
              color: UIColors.textBody,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
          20.gap,
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.map,
                  iconColor: UIColors.pink,
                  value: '4.2 km',
                  label: 'Quãng đường',
                ),
              ),
              12.gap,
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.deepOrange,
                  value: '4.2 km',
                  label: 'Năng lượng',
                ),
              ),
            ],
          ),
          20.gap,
          const WaterGoalCard(),
          12.gap,
          const HeartRateCard(),
        ],
      ),
    );
  }
}