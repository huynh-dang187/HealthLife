import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_cubit.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../set_goal_dialog.dart';
import '../step_progress_ring.dart';
import '../streaks/streak_badge.dart';
import 'card/heart_rate_card.dart';
import 'stat_card.dart';
import 'card/water_goal_card.dart';

/// Nội dung tab "Tổng quan": ring, streak, thống kê và các card nhanh.
class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.streak,
    required this.currentSteps,
    required this.goalSteps,
    required this.status,
    this.error,
  });

  final int streak;
  final int currentSteps;
  final int goalSteps;
  final BlocStatus status;
  final String? error;

  /// Chiều dài sải chân trung bình (m) và kcal/1 bước dùng để ước tính.
  static const _avgStrideMeters = 0.7;
  static const _kcalPerStep = 0.04;

  @override
  Widget build(BuildContext context) {
    final ringSize = (context.screenWidth - 48) * 0.7;
    final cubit = context.read<ActivityDashboardCubit>();

    final distanceKm = (currentSteps * _avgStrideMeters / 1000);
    final energyKcal = (currentSteps * _kcalPerStep);

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
              child: StepProgressRing(
                currentSteps: currentSteps,
                goalSteps: goalSteps,
                onEditGoal: () => showSetGoalDialog(
                  context,
                  cubit: cubit,
                  initialGoal: goalSteps,
                ),
              ),
            ),
          ),
          24.gap,
          Center(
            child: AppText.regular(
              context.tr(
                LocaleKeys.count_steep_streak_message,
                namedArgs: {'streak': '$streak'},
              ),
              fontSize: 13,
              color: UIColors.textBody,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
          if (status == BlocStatus.failure && error != null) ...[
            12.gap,
            Center(
              child: AppText.regular(
                context.tr(LocaleKeys.count_steep_permission_denied),
                fontSize: 12,
                color: UIColors.error,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          20.gap,
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.map,
                  iconColor: UIColors.pink,
                  value: '${distanceKm.toStringAsFixed(1)} km',
                  label: context.tr(LocaleKeys.count_steep_distance),
                ),
              ),
              12.gap,
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.deepOrange,
                  value: '${energyKcal.round()} kcal',
                  label: context.tr(LocaleKeys.count_steep_energy),
                ),
              ),
            ],
          ),
          20.gap,
          WaterGoalCard(
            onLogWaterTap: () => context.push(RouteNames.water_reminder),
          ),
          12.gap,
          const HeartRateCard(),
        ],
      ),
    );
  }
}