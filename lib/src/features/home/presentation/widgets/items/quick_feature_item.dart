import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class QuickFeatureItem extends StatelessWidget {
  const QuickFeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  final Widget icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Center(child: icon),
            ),
          ),
          8.gap,
          AppText.semiBold(
            title,
            fontSize: 11,
            color: UIColors.text,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
