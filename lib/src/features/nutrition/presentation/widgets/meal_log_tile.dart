import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:intl/intl.dart';

import '../../data/model/meal_log_model.dart';

/// 1 item trong "Nhật ký ăn".
class MealLogTile extends StatelessWidget {
  const MealLogTile({super.key, required this.log, this.onTap});

  final MealLogModel log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UIColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: UIColors.pinkLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  size: 18,
                  color: UIColors.pink,
                ),
              ),
              12.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                      log.foodName,
                      fontSize: 13,
                      maxLines: 1,
                      color: UIColors.text,
                    ),
                    4.gap,
                    AppText.regular(
                      '${log.calo.round() > 0 ? log.calo.round() : 0} kcal'
                      ' • ${DateFormat('HH:mm').format(log.mealTime)}'
                      ' • ${_grams(log.grams)}',
                      fontSize: 11.5,
                      color: UIColors.textBody,
                    ),
                  ],
                ),
              ),
              8.gap,
              Assets.svg.icChevronRight.svg(
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  UIColors.textBody,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _grams(double g) {
    final r = g.round();
    return r == g ? '$r g' : '${g.toStringAsFixed(1)} g';
  }
}