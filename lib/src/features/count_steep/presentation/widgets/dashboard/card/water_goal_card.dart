import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Card "Ghi lại lượng nước uống" — nền tối.
class WaterGoalCard extends StatelessWidget {
  const WaterGoalCard({
    super.key,
    this.onLogWaterTap,
  });

  final VoidCallback? onLogWaterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIColors.darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop,
              size: 22,
              color: Colors.lightBlueAccent,
            ),
          ),
          14.gap,
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold(
                  context.tr(LocaleKeys.count_steep_card_water_title),
                  fontSize: 14,
                  color: UIColors.white,
                ),
                3.gap,
                AppText.regular(
                  context.tr(LocaleKeys.count_steep_card_water_sub),
                  fontSize: 11.5,
                  color: UIColors.white.withValues(alpha: 0.65),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          12.gap,
          Expanded(
            child: AppButton.fill(
              title: 'Chi tiết',
              height: 34,
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(18),
              fontSize: 12,
              enable: true,
              onTap: onLogWaterTap ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}
