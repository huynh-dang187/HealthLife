import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

class DrawerSearchBar extends StatelessWidget {
  const DrawerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: UIColors.text,
          ),
        ),
        12.gap,
        Expanded(
          child: SizedBox(
            height: 40,
            child: AppTF.common(
              controller: controller,
              hintText: LocaleKeys.chatbot_history_search_hint,
              height: 40,
              borderCicular: 20,
              bgColor: const Color(0xFFF3F8F5),
              textColor: UIColors.text,
              leftWidget: Assets.svg.iconSearch.svg(
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  UIColors.textBody,
                  BlendMode.srcIn,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}