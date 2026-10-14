import 'package:flutter/material.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/summary_card/presentation/widgets/step_summary_card.dart';
import 'package:healthlife/src/features/summary_card/presentation/widgets/water_summary_card.dart';

/// Hàng gồm 2 card tóm tắt sức khỏe (Nước + Bước chân), cao bằng nhau.
class HealthSummaryRow extends StatelessWidget {
  const HealthSummaryRow({
    super.key,
    required this.currentLiters,
    required this.goalLiters,
    required this.cupCount,
    required this.currentSteps,
    required this.goalSteps,
    required this.streakDays,
    this.onWaterTap,
    this.onWaterAddTap,
    this.onStepTap,
  });

  final double currentLiters;
  final double goalLiters;
  final int cupCount;
  final int currentSteps;
  final int goalSteps;
  final int streakDays;
  final VoidCallback? onWaterTap;
  final VoidCallback? onWaterAddTap;
  final VoidCallback? onStepTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: WaterSummaryCard(
                currentLiters: currentLiters,
                goalLiters: goalLiters,
                cupCount: cupCount,
                onTap: onWaterTap,
                onAddTap: onWaterAddTap,
              ),
            ),
            12.gap,
            Expanded(
              child: StepSummaryCard(
                currentSteps: currentSteps,
                goalSteps: goalSteps,
                streakDays: streakDays,
                onTap: onStepTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
