import 'package:flutter/material.dart';
import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';

class QuickAddWaterSection extends StatelessWidget {
  final Function(int amount) onAddWater;
  final VoidCallback onCustomTap;

  const QuickAddWaterSection({
    super.key,
    required this.onAddWater,
    required this.onCustomTap,
  });

  static const List<int> defaultAmounts = [100, 150, 200, 300, 400];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bold(
          'Thêm nhanh lượng nước',
          fontSize: 16,
          color: UIColors.text,
        ),
        12.gap,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...defaultAmounts.map((amount) {
              return _buildQuickAddChip(
                context,
                label: '+$amount ml',
                icon: Icons.local_drink,
                onTap: () => onAddWater(amount),
              );
            }),
            _buildQuickAddChip(
              context,
              label: 'Tùy chỉnh',
              icon: Icons.tune,
              isCustom: true,
              onTap: onCustomTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isCustom
                ? theme.primaryColor.withValues(alpha: 0.1)
                : const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCustom
                  ? theme.primaryColor.withValues(alpha: 0.4)
                  : const Color(0xFF80DEEA),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isCustom ? theme.primaryColor : const Color(0xFF0083B0),
              ),
              6.gap,
              AppText.semiBold(
                label,
                fontSize: 14,
                color: isCustom ? theme.primaryColor : const Color(0xFF006064),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
