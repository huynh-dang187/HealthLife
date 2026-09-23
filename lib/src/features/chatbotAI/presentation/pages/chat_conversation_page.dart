import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/chat_history_drawer.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static final _today = DateTime.now();
  static DateTime _daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

  @override
  Widget build(BuildContext context) {
    const testRemaining = 10;
    const testTotal = 50;

    final sessions = [
      ChatSessionItem(
        id: 1,
        title: 'Thực đơn cho người tiểu đường',
        lastUpdate: _today,
        pinned: true,
      ),
      ChatSessionItem(
        id: 2,
        title: 'Cách giảm đau đầu hiệu quả',
        lastUpdate: _today,
      ),
      ChatSessionItem(
        id: 3,
        title: 'Đánh giá chỉ số BMI',
        lastUpdate: _today,
      ),
      ChatSessionItem(
        id: 4,
        title: 'Tác dụng của Vitamin C',
        lastUpdate: _daysAgo(3),
      ),
      ChatSessionItem(
        id: 5,
        title: 'Lịch tiêm phòng cho trẻ',
        lastUpdate: _daysAgo(5),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFFFF9FA),
      endDrawer: ChatHistoryDrawer(
        sessions: sessions,
        onNewChat: () {
          Navigator.pop(context);
          // TODO: bắt đầu phiên mới
        },
        onIntroTap: () {
          Navigator.pop(context);
          Navigator.pop(context); // về trang giới thiệu
        },
        onSelectSession: (session) {
          Navigator.pop(context);
          // TODO: tải lịch sử phiên
        },
      ),
      appBar: AppAppBar(
        centerTitle: true,
        title: LocaleKeys.chatbot_chat_new_title.tr(),
        titleColor: UIColors.text,
        rightBtns: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onMenuTap ??
                () => _scaffoldKey.currentState?.openEndDrawer(),
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
