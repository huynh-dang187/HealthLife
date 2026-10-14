import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Card tóm tắt "Bước chân" — widget "ngu", chỉ nhận tham số, không gọi Cubit.
class StepSummaryCard extends StatelessWidget {
  const StepSummaryCard({
    super.key,
    required this.currentSteps,
    required this.goalSteps,
    required this.streakDays,
    this.onTap,
  });

  final int currentSteps;
  final int goalSteps;
  final int streakDays;
  final VoidCallback? onTap;

  static final NumberFormat _stepFormat = NumberFormat.decimalPattern('vi_VN');

  @override
  Widget build(BuildContext context) {
    final progress = goalSteps <= 0
        ? 0.0
        : (currentSteps / goalSteps).clamp(0.0, 1.0);
    final percent = goalSteps <= 0
        ? 0
        : ((currentSteps / goalSteps) * 100).round().clamp(0, 100);
    const accent = UIColors.coral;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    size: 19,
                    color: accent,
                  ),
                ),
                8.gap,
                Expanded(
                  child: AppText.semiBold(
                    context.tr(LocaleKeys.home_summary_step_title),
                    fontSize: 14,
                    color: accent,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            12.gap,
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AppText.bold(
                    _stepFormat.format(currentSteps),
                    fontSize: 30,
                    color: accent,
                    maxLines: 1,
                  ),
                  const SizedBox(width: 4),
                  AppText.regular(
                    context.tr(
                      LocaleKeys.home_summary_step_goal,
                      namedArgs: {'goal': _stepFormat.format(goalSteps)},
                    ),
                    fontSize: 12,
                    color: UIColors.textBody,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            10.gap,
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: accent.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            8.gap,
            AppText.regular(
              context.tr(
                LocaleKeys.home_summary_step_percent,
                namedArgs: {'percent': percent.toString()},
              ),
              fontSize: 11,
              color: UIColors.textBody,
              maxLines: 1,
            ),
            12.gap,
            Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 16,
                    color: accent,
                  ),
                  4.gap,
                  Flexible(
                    child: AppText.semiBold(
                      context.tr(
                        LocaleKeys.home_summary_step_streak,
                        namedArgs: {'days': streakDays.toString()},
                      ),
                      fontSize: 13,
                      color: accent,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
