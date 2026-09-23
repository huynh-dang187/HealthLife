import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/fonts.gen.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/chatbotAI/data/models/chat_message_model.dart';

/// Bong bóng một tin nhắn trong cuộc trò chuyện BiBi.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
  });

  final ChatMessageModel message;
  final bool showAvatar;

  bool get isUser => message.role == ChatMessageRole.user;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF1FBF67) : UIColors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        border: isUser
            ? null
            : Border.all(color: const Color(0xFFEEF1EF), width: 1),
        boxShadow: isUser
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, 1),
                  blurRadius: 6,
                ),
              ],
      ),
      child: Text(
        message.content,
        softWrap: true,
        style: TextStyle(
          fontSize: 14,
          color: isUser ? UIColors.white : UIColors.text,
          height: 1.4,
          fontFamily: FontFamily.inter,
        ),
      ),
    );

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAvatar) ...[
          ClipOval(
            child: Assets.png.icChatbotAI.image(
              width: 30,
              height: 30,
              filterQuality: FilterQuality.high,
            ),
          ),
          8.gap,
        ],
        Flexible(
          child: Align(alignment: Alignment.centerLeft, child: bubble),
        ),
      ],
    );
  }
}
