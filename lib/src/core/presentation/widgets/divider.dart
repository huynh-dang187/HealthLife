import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height, this.color});

  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 1,
      thickness: height ?? 1,
      color: color ?? UIColors.pink,
    );
  }
}
