import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/intro/ai_card.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/intro/feature_point_card.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/intro/highlights_row.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/intro/intro_info_blocks.dart';

class ChatbotIntroPage extends StatelessWidget {
  const ChatbotIntroPage({super.key, this.onStartChat});

  final VoidCallback? onStartChat;

  static const _softGreen = Color(0xFF3ECF70);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.white,
      appBar: AppAppBar(
        title: LocaleKeys.chatbot_intro_title.tr(),
        bgColor: UIColors.white,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.paddingOf(context).bottom + 10,
        ),
        children: [
          const AiCard(),
          16.gap,
          const HighlightsRow(),
          24.gap,
          ...FeaturePoint.list.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: FeaturePointCard(data: point),
            ),
          ),
          8.gap,
          const IntroInfoBlocks(),
          24.gap,
          AppButton.fill(
            onTap: onStartChat ?? () {},
            title: LocaleKeys.chatbot_intro_start_button.tr(),
            color: _softGreen,
            height: 52,
            borderRadius: BorderRadius.circular(16),
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
