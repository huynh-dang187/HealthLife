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
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/suggested_prompts_grid.dart';

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  @override
  Widget build(BuildContext context) {
    const testRemaining = 10;
    const testTotal = 50;

    return Scaffold(
      backgroundColor: Color(0xFFFFF9FA),
      appBar: AppAppBar(
        centerTitle: true,
        title: LocaleKeys.chatbot_chat_new_title.tr(),
        titleColor: UIColors.text,
        rightBtns: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onMenuTap,
            child: Assets.svg.icDrawer.svg(
              width: 18,
              height: 18,
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
                  ],
                ),
              ),
            ),
            _ChatBottomBar(
              bottomInset: context.bottomPadding,
              remaining: testRemaining,
              total: testTotal,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBottomBar extends StatelessWidget {
  const _ChatBottomBar({
    required this.bottomInset,
    required this.remaining,
    required this.total,
  });

  final double bottomInset;
  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        bottomInset > 0 ? bottomInset : 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          UsageRemainingText(
            remaining: remaining,
            total: total,
          ),
          6.gap,
          ChatInputBar(
            remaining: remaining,
            total: total,
          ),
        ],
      ),
    );
  }
}
