import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class ChatWelcome extends StatelessWidget {
  const ChatWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8F7EE),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1FBF67).withValues(alpha: 30),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFF1FBF67).withValues(alpha: 12),
                blurRadius: 48,
                spreadRadius: 4,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF1FBF67).withValues(alpha: 40),
              width: 1.5,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: Assets.png.icChatbotAI.image(
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        18.gap,
        AppText.bold(
          LocaleKeys.chatbot_ai_name.tr(),
          fontSize: 30,
          color: const Color(0xFF1FBF67),
          fontWeight: FontWeight.w800,
        ),
        10.gap,
        AppText.regular(
          LocaleKeys.chatbot_chat_welcome.tr(),
          fontSize: 14,
          color: UIColors.textBody,
          textAlign: TextAlign.center,
          height: 1.5,
        ),
      ],
    );
  }
}