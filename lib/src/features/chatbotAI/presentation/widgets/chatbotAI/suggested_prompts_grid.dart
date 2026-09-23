import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class SuggestedPrompt {
  const SuggestedPrompt({
    required this.icon,
    required this.labelKey,
    required this.iconColor,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final String labelKey;
  final Color iconColor;
  final Color background;
  final Color border;

  static const List<SuggestedPrompt> all = [
    SuggestedPrompt(
      icon: Icons.restaurant,
      labelKey: LocaleKeys.chatbot_chat_prompt_diabetic_diet,
      iconColor: Color(0xFF1FBF67),
      background: Color(0xFFE8F7EE),
      border: Color(0xFFCBEBD8),
    ),
    SuggestedPrompt(
      icon: Icons.fitness_center,
      labelKey: LocaleKeys.chatbot_chat_prompt_home_exercise,
      iconColor: Color(0xFF2F80ED),
      background: Color(0xFFE8F1FD),
      border: Color(0xFFCDE1F7),
    ),
    SuggestedPrompt(
      icon: Icons.local_hospital,
      labelKey: LocaleKeys.chatbot_chat_prompt_doctor_signs,
      iconColor: Color(0xFFE8822F),
      background: Color(0xFFFDF2E6),
      border: Color(0xFFF7E0C8),
    ),
    SuggestedPrompt(
      icon: Icons.bedtime,
      labelKey: LocaleKeys.chatbot_chat_prompt_better_sleep,
      iconColor: Color(0xFF8B5CF6),
      background: Color(0xFFF1EEFC),
      border: Color(0xFFDDD6F5),
    ),
  ];
}

class SuggestedPromptsGrid extends StatelessWidget {
  const SuggestedPromptsGrid({super.key, this.onPromptTap});

  final ValueChanged<String>? onPromptTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 104,
      ),
      itemCount: SuggestedPrompt.all.length,
      itemBuilder: (context, index) {
        final item = SuggestedPrompt.all[index];
        final label = item.labelKey.tr();
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onPromptTap?.call(label),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UIColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: item.iconColor),
                ),
                const Spacer(),
                AppText.semiBold(
                  label,
                  fontSize: 13,
                  color: UIColors.text,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}