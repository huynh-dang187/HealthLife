import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Card tóm tắt "Uống nước" — widget "ngu", chỉ nhận tham số, không gọi Cubit.
class WaterSummaryCard extends StatelessWidget {
  const WaterSummaryCard({
    super.key,
    required this.currentLiters,
    required this.goalLiters,
    required this.cupCount,
    this.onTap,
    this.onAddTap,
  });

  final double currentLiters;
  final double goalLiters;
  final int cupCount;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  static final NumberFormat _literFormat = NumberFormat('0.0', 'en_US');

  @override
  Widget build(BuildContext context) {
    final progress = goalLiters <= 0
        ? 0.0
        : (currentLiters / goalLiters).clamp(0.0, 1.0);
    const accent = UIColors.vibrantBlue;

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
                _HeaderIcon(icon: Icons.water_drop_rounded, color: accent),
                8.gap,
                Expanded(
                  child: AppText.semiBold(
                    context.tr(LocaleKeys.home_summary_water_title),
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
                    _literFormat.format(currentLiters),
                    fontSize: 30,
                    color: accent,
                    maxLines: 1,
                  ),
                  const SizedBox(width: 4),
                  AppText.regular(
                    context.tr(
                      LocaleKeys.home_summary_water_goal,
                      namedArgs: {'goal': _literFormat.format(goalLiters)},
                    ),
                    fontSize: 12,
                    color: UIColors.textBody,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            10.gap,
            _ProgressBar(progress: progress, color: accent),
            8.gap,
            AppText.regular(
              context.tr(
                LocaleKeys.home_summary_water_subtitle,
                namedArgs: {'count': cupCount.toString()},
              ),
              fontSize: 11,
              color: UIColors.textBody,
              maxLines: 1,
            ),
            12.gap,
            _ActionButton(
              label: context.tr(LocaleKeys.home_summary_water_add),
              color: accent,
              onTap: onAddTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 19, color: color),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 7,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AppText.semiBold(
          label,
          fontSize: 13,
          color: color,
          maxLines: 1,
        ),
      ),
    );
  }
}
