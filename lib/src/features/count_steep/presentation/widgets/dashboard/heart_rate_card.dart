import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Card "Theo dõi nhịp tim" — nền tối, nút Đo disabled + badge Sắp ra mắt.
class HeartRateCard extends StatelessWidget {
  const HeartRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: UIColors.pink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 22,
                  color: UIColors.pink,
                ),
              ),
              14.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.semiBold(
                      'Theo dõi nhịp tim',
                      fontSize: 14,
                      color: UIColors.white,
                    ),
                    3.gap,
                    AppText.regular(
                      'Đo nhanh nhịp tim của bạn',
                      fontSize: 11.5,
                      color: UIColors.white.withValues(alpha: 0.65),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              12.gap,
              AppButton.fill(
                title: 'Đo',
                width: 64,
                height: 34,
                color: UIColors.pink,
                borderRadius: BorderRadius.circular(18),
                fontSize: 12,
                enable: false,
                onTap: () {},
              ),
            ],
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: UIColors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: UIColors.white.withValues(alpha: 0.15)),
              ),
              child: AppText.medium(
                'Sắp ra mắt',
                fontSize: 9,
                color: UIColors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}