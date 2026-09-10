import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';

class GenderOption extends StatelessWidget {
  final Widget image;
  final Gender gender;
  final bool isSelected;
  final VoidCallback? onTap;

  const GenderOption({
    super.key,
    required this.image,
    required this.gender,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? UIColors.vibrantBlue : UIColors.dustyRose,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            image,
            11.gap,
            AppText.bold(
              gender.label,
              fontSize: 26,
            ),
          ],
        ),
      ),
    );
  }
}
