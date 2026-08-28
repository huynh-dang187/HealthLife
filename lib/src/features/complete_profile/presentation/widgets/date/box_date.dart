import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

class DateFieldItem extends StatelessWidget {
  const DateFieldItem({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    required this.maxNum,
    this.hintText = '',
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxNum;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bold(label),
          6.gap,
          AppTF.common(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxNum),
            ],
            hintText: hintText,
          ),
        ],
      ),
    );
  }
}
