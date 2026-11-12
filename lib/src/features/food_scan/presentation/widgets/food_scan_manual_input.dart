import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';

class FoodScanManualInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onAnalyze;

  const FoodScanManualInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'manual_input_title'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: UIColors.text,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: UIColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: UIColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: UIColors.text,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'manual_input_hint'.tr(),
                    hintStyle: const TextStyle(
                      color: UIColors.textBody,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.text_fields,
                      color: UIColors.textBody,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => onAnalyze(controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColors.pink,
                  foregroundColor: UIColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                ),
                icon: Assets.png.icFind.image(
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  'analyze_button'.tr(),
                  style: const TextStyle(
                    color: UIColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}