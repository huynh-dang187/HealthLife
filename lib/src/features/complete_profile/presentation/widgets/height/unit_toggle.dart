import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';

class UnitToggle extends StatelessWidget {
  const UnitToggle({super.key, required this.value, required this.onChanged});

  final HeightUnit value;
  final ValueChanged<HeightUnit> onChanged;

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
          _segment(HeightUnit.cm, 'cm'),
          _segment(HeightUnit.ft, 'ft'),
        ],
      ),
    );
  }

  Widget _segment(HeightUnit unit, String label) {
    final selected = value == unit;
    return GestureDetector(
      onTap: () => onChanged(unit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? UIColors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AppText.medium(
          label,
          fontSize: 13,
          color: selected ? Colors.white : UIColors.textBody,
        ),
      ),
    );
  }
}
