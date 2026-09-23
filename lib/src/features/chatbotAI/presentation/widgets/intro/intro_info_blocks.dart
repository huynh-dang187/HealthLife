import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';

import 'info_block.dart';

class IntroInfoBlockConfig {
  const IntroInfoBlockConfig({
    required this.titleKey,
    required this.descriptionKey,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String titleKey;
  final String descriptionKey;
  final Color color;
  final Color background;
  final IconData icon;

  static const List<IntroInfoBlockConfig> all = [
    IntroInfoBlockConfig(
      titleKey: LocaleKeys.chatbot_intro_block_secure_title,
      descriptionKey: LocaleKeys.chatbot_intro_block_secure_desc,
      color: Color(0xFF34C759),
      background: Color(0xFFF2FBF5),
      icon: Icons.shield_outlined,
    ),
    IntroInfoBlockConfig(
      titleKey: LocaleKeys.chatbot_intro_block_medical_title,
      descriptionKey: LocaleKeys.chatbot_intro_block_medical_desc,
      color: Color(0xFF8B5CF6),
      background: Color(0xFFF7F4FF),
      icon: Icons.auto_awesome,
    ),
    IntroInfoBlockConfig(
      titleKey: LocaleKeys.chatbot_intro_block_notice_title,
      descriptionKey: LocaleKeys.chatbot_intro_block_notice_desc,
      color: Color(0xFFF59E0B),
      background: Color(0xFFFFF9EF),
      icon: Icons.warning_amber_rounded,
    ),
  ];
}

class IntroInfoBlocks extends StatelessWidget {
  const IntroInfoBlocks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < IntroInfoBlockConfig.all.length; i++) ...[
          if (i > 0) 12.gap,
          InfoBlock(
            title: IntroInfoBlockConfig.all[i].titleKey.tr(),
            description: IntroInfoBlockConfig.all[i].descriptionKey.tr(),
            color: IntroInfoBlockConfig.all[i].color,
            background: IntroInfoBlockConfig.all[i].background,
            icon: IntroInfoBlockConfig.all[i].icon,
          ),
        ],
      ],
    );
  }
}
