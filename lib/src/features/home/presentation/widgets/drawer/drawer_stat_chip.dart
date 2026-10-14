import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Chip nhỏ hiển thị một chỉ số (bước chân / nước) trong header drawer.
class DrawerStatChip extends StatelessWidget {
  const DrawerStatChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: UIColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: UIColors.white),
          8.gap,
          Expanded(
            child: AppText.semiBold(
              label,
              fontSize: 13,
              color: UIColors.white,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
