import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/fonts.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/features/chatbotAI/data/models/chat_message_model.dart';
import 'package:healthlife/src/features/chatbotAI/data/repositories/chatbot_repository.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/cubit/chat_conversation_cubit.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/cubit/chat_conversation_state.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/cubit/chat_session_list_cubit.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/cubit/chat_session_list_state.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/chat_input_bar.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/chat_message_bubble.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/chat_welcome.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/chatbotAI/suggested_prompts_grid.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/chat_history_drawer.dart';

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ChatbotRepository _repository = ChatbotRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ChatConversationCubit(_repository),
        ),
        BlocProvider(
          create: (context) => ChatSessionListCubit(_repository),
        ),
      ],
      child: BlocListener<ChatConversationCubit, ChatConversationState>(
        listener: (context, state) {
          final error = state.error;
          if (error == null || error.isEmpty) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  error,
                  style: const TextStyle(
                    fontSize: 14,
                    color: UIColors.white,
                    fontFamily: FontFamily.inter,
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFE8434F),
              ),
            );
        },
        child: BlocBuilder<ChatSessionListCubit, ChatSessionListState>(
          builder: (context, listState) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: const Color(0xFFFFF9FA),
              endDrawer: ChatHistoryDrawer(
                sessions: listState.sessions,
                onNewChat: () {
                  Navigator.pop(context);
                  context.read<ChatConversationCubit>().startNewSession();
                },
                onIntroTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                onSelectSession: (session) {
                  Navigator.pop(context);
                  context.read<ChatConversationCubit>().openSession(session.id);
                },
                onTogglePin: (session, pinned) {
                  context.read<ChatSessionListCubit>().togglePin(
                    session.id,
                    pinned,
                  );
                },
                onRename: (session, newTitle) {
                  context.read<ChatSessionListCubit>().rename(
                    session.id,
                    newTitle,
                  );
                },
                onDelete: (session) {
                  context.read<ChatSessionListCubit>().delete(session.id);
                },
              ),
              appBar: AppAppBar(
                centerTitle: true,
                title: LocaleKeys.chatbot_chat_new_title.tr(),
                titleColor: UIColors.text,
                rightBtns: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap:
                        widget.onMenuTap ??
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
                child:
                    BlocBuilder<ChatConversationCubit, ChatConversationState>(
                      builder: (context, state) {
                        final conversation = context
                            .read<ChatConversationCubit>();
                        final hasMessages = state.messages.isNotEmpty;

                        return Column(
                          children: [
                            Expanded(
                              child: hasMessages
                                  ? _MessageList(messages: state.messages)
                                  : SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        8,
                                        20,
                                        16,
                                      ),
                                      child: Column(
                                        children: [
                                          const ChatWelcome(),
                                          28.gap,
                                          SuggestedPromptsGrid(
                                            onPromptTap: (label) =>
                                                conversation.sendMessage(label),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            _ChatBottomBar(
                              bottomInset: context.bottomPadding,
                              remaining: state.remaining,
                              total: state.total,
                              sending: state.sending,
                              onSend: conversation.sendMessage,
                            ),
                          ],
                        );
                      },
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Danh sách tin nhắn, tuỳ chỉnh được scroll + giữ cuối màn hình mỗi khi có tin mới.
class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<ChatMessageModel> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ChatMessageBubble(
            message: message,
            showAvatar: message.role == ChatMessageRole.assistant,
          ),
        );
      },
    );
  }
}

class _ChatBottomBar extends StatelessWidget {
  const _ChatBottomBar({
    required this.bottomInset,
    required this.remaining,
    required this.total,
    required this.sending,
    required this.onSend,
  });

  final double bottomInset;
  final int remaining;
  final int total;
  final bool sending;
  final ValueChanged<String> onSend;

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
          UsageRemainingText(remaining: remaining, total: total),
          6.gap,
          ChatInputBar(
            remaining: remaining,
            total: total,
            enabled: !sending,
            onSend: onSend,
          ),
          if (sending)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                LocaleKeys.chatbot_chat_typing.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: UIColors.textBody,
                  fontFamily: FontFamily.inter,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
