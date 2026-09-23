import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/chat_input_bar.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/chat_welcome.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/suggested_chips.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/suggested_prompts_grid.dart';

class ChatConversationPage extends StatelessWidget {
  const ChatConversationPage({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF8),
      appBar: AppAppBar(
        title: LocaleKeys.chatbot_chat_new_title.tr(),
        bgColor: UIColors.white,
        iconColor: const Color(0xFF1FBF67),
        titleColor: UIColors.text,
        rightBtns: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMenuTap,
            child: Assets.svg.icDrawer.svg(
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1FBF67),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    const ChatWelcome(),
                    28.gap,
                    const SuggestedPromptsGrid(),
                    24.gap,
                    // const SuggestedChips(),
                    18.gap,
                    const UsageRemainingText(),
                  ],
                ),
              ),
            ),
            _ChatBottomBar(
              bottomInset: context.bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBottomBar extends StatelessWidget {
  const _ChatBottomBar({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        bottomInset > 0 ? bottomInset : 6,
      ),

      child: const ChatInputBar(),
    );
  }
}
