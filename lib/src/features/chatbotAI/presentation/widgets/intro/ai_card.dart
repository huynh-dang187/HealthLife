import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class AiCard extends StatelessWidget {
  const AiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: AiCardColors.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AiCardColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          ClipOval(
            child: Assets.png.icChatbotAI.image(
              width: 108,
              height: 108,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          16.gap,
          AppText.bold(
            LocaleKeys.chatbot_ai_name.tr(),
            fontSize: 26,
            color: AiCardColors.title,
          ),
          6.gap,
          AppText.regular(
            LocaleKeys.chatbot_intro_tagline.tr(),
            fontSize: 13,
            color: AiCardColors.subtitle,
            textAlign: TextAlign.center,
            height: 1.5,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class AiCardColors {
  AiCardColors._();

  static const bg = Color(0xFFE3F0FB);
  static const border = Color(0xFFBBDDF5);
  static const title = Color(0xFF0B3D6E);
  static const subtitle = Color(0xFF4A6B8A);
}
