import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class InfoBlock extends StatelessWidget {
  const InfoBlock({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String title;
  final String description;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold(title, fontSize: 14),
                4.gap,
                AppText.regular(
                  description,
                  fontSize: 12,
                  color: UIColors.textBody,
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
