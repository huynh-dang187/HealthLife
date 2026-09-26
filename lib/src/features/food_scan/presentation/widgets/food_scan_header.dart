import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';

class FoodScanHeader extends StatelessWidget {
  const FoodScanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Assets.svg.icArrowLeft.svg(
            colorFilter: const ColorFilter.mode(
              UIColors.black,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: Text(
            'food_scan_title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIColors.black,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}