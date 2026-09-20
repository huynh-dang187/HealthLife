import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../set_goal_dialog.dart';

/// Card "Ghi lại lượng nước uống" — nền tối, nút Đặt mục tiêu mở dialog.
class WaterGoalCard extends StatelessWidget {
  const WaterGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold(
                  'Ghi lại lượng nước uống',
                  fontSize: 14,
                  color: UIColors.white,
                ),
                3.gap,
                AppText.regular(
                  'Nhắc uống đủ nước mỗi ngày để khỏe hơn',
                  fontSize: 11.5,
                  color: UIColors.white.withValues(alpha: 0.65),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          12.gap,
          AppButton.fill(
            title: 'Đặt mục tiêu',
            height: 34,
            color: UIColors.pink,
            borderRadius: BorderRadius.circular(18),
            fontSize: 12,
            onTap: () => showSetGoalDialog(context),
          ),
        ],
      ),
    );
  }
}