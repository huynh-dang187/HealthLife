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
          decoration: const BoxDecoration(shape: BoxShape.circle),
          clipBehavior: Clip.antiAlias,
          child: Assets.png.icChatbotAI.image(
            width: 170,
            height: 170,
            filterQuality: FilterQuality.high,
          ),
        ),
        2.gap,
        AppText.bold(
          LocaleKeys.chatbot_ai_name.tr(),
          fontSize: 30,
          color: UIColors.pink,
          fontWeight: FontWeight.w800,
        ),
        10.gap,
        AppText.regular(
          LocaleKeys.chatbot_chat_welcome.tr(),
          fontSize: 14,
          color: UIColors.textBody,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    );
  }
}
