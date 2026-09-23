import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class SuggestedChips extends StatelessWidget {
  const SuggestedChips({super.key, this.onChipTap});

  final ValueChanged<String>? onChipTap;

  @override
  Widget build(BuildContext context) {
    final chips = [
      LocaleKeys.chatbot_chat_chip_nutrition,
      LocaleKeys.chatbot_chat_chip_exercise,
      LocaleKeys.chatbot_chat_chip_sleep,
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips
            .map(
              (key) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChipTap?.call(key.tr()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: UIColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1FBF67).withValues(alpha: 30),
                      width: 1,
                    ),
                  ),
                  child: AppText.regular(
                    key.tr(),
                    fontSize: 12.5,
                    color: UIColors.text,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class UsageRemainingText extends StatelessWidget {
  const UsageRemainingText({super.key, this.remaining = 40, this.total = 50});

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppText.regular(
      LocaleKeys.chatbot_chat_usage_remaining.tr(
        namedArgs: {
          'remaining': '$remaining',
          'total': '$total',
        },
      ),
      fontSize: 12,
      color: UIColors.textBody,
    );
  }
}