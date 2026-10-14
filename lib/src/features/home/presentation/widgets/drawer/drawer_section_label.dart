import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Nhãn tiêu đề một nhóm mục trong drawer.
class DrawerSectionLabel extends StatelessWidget {
  const DrawerSectionLabel(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText.semiBold(
      title,
      fontSize: 13,
      color: UIColors.textBody,
    );
  }
}
