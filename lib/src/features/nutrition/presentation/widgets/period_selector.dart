import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../cubit/nutrition_dashboard_state.dart';

/// Bộ chuyển đổi Ngày / Tuần / Tháng / Năm.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final NutritionPeriod selected;
  final ValueChanged<NutritionPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          for (final period in NutritionPeriod.values) ...[
            if (period != NutritionPeriod.values.first) 4.gap,
            Expanded(
              child: _PeriodChip(
                label: period.vn,
                selected: selected == period,
                onTap: () => onChanged(period),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? UIColors.pink : Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: AppText.medium(
              label,
              fontSize: 13,
              color: selected ? UIColors.white : UIColors.textBody,
            ),
          ),
        ),
      ),
    );
  }
}