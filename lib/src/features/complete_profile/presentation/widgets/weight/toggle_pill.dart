import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class TogglePill extends StatelessWidget {
  const TogglePill({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++) _segment(i),
        ],
      ),
    );
  }

  Widget _segment(int index) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? UIColors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AppText.medium(
          labels[index],
          color: selected ? Colors.white : UIColors.textBody,
        ),
      ),
    );
  }
}
