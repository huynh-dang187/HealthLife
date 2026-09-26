import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/count_steep/domains/enums/activity_period.dart';

class PeriodTabs extends StatelessWidget {
  const PeriodTabs({super.key, required this.selected, required this.onChanged});

  final ActivityPeriod selected;
  final ValueChanged<ActivityPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final period in ActivityPeriod.values)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(period),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.semiBold(
                  context.tr(period.labelKey),
                  fontSize: 14,
                  color: period == selected
                      ? UIColors.coral
                      : UIColors.textBody,
                ),
                6.gap,
                Container(
                  width: period == selected ? 28 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: UIColors.coral,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}