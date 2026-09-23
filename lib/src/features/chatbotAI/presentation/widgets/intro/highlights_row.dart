import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class HighlightsRow extends StatelessWidget {
  const HighlightsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.translate,
        label: LocaleKeys.chatbot_intro_multi_lang.tr(),
      ),
      (
        icon: Icons.schedule,
        label: LocaleKeys.chatbot_intro_available_24_7.tr(),
      ),
      (
        icon: Icons.smart_toy,
        label: LocaleKeys.chatbot_intro_ai_platform.tr(),
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD6E8FF),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        item.icon,
                        size: 18,
                        color: const Color(0xFF2F80ED),
                      ),
                      4.gap,
                      AppText.medium(
                        item.label,
                        fontSize: 11,
                        color: const Color(0xFF2F80ED),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}