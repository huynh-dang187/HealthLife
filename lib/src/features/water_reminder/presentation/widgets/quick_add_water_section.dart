import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';

class QuickAddWaterSection extends StatelessWidget {
  final Function(int amount) onAddWater;
  final VoidCallback onCustomTap;

  const QuickAddWaterSection({
    super.key,
    required this.onAddWater,
    required this.onCustomTap,
  });

  static const List<int> defaultAmounts = [100, 150, 200, 300, 400];

  static const _primaryColor = Color(0xFF0288D1);
  static const _waterColor = Color(0xFFE3F5FC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0EEF4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _waterColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: _primaryColor,
                  size: 21,
                ),
              ),
              10.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      context.tr(LocaleKeys.water_reminder_quick_add),
                      fontSize: 16,
                      color: UIColors.text,
                    ),
                    2.gap,
                    AppText.regular(
                      context.tr(LocaleKeys.water_reminder_quick_add_sub),
                      fontSize: 11,
                      color: UIColors.textBody,
                    ),
                  ],
                ),
              ),
            ],
          ),

          16.gap,

          // Quick add buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...defaultAmounts.map(
                (amount) => _buildQuickAddButton(
                  context,
                  amount: amount,
                  onTap: () => onAddWater(amount),
                ),
              ),
              _buildCustomButton(
                context,
                onTap: onCustomTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context, {
    required int amount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _waterColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFB8E4F2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                size: 17,
                color: _primaryColor,
              ),
              3.gap,
              AppText.semiBold(
                '$amount ml',
                fontSize: 13,
                color: const Color(0xFF006B96),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 17,
                color: Colors.white,
              ),
              5.gap,
              AppText.semiBold(
                context.tr(LocaleKeys.water_reminder_custom),
                fontSize: 13,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
