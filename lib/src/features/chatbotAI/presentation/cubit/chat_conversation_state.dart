import 'package:healthlife/src/features/chatbotAI/data/models/chat_message_model.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

/// Trạng thái của phiên trò chuyện đang mở.
final class ChatConversationState {
  const ChatConversationState({
    this.status = BlocStatus.initial,
    this.messages = const [],
    this.sending = false,
    this.remaining = 50,
    this.total = 50,
    this.error,
  });

  final BlocStatus status;
  final List<ChatMessageModel> messages;
  final bool sending;

  /// Lượt còn lại + tổng lượt của ngày (đưa vào UI).
  final int remaining;
  final int total;
  final String? error;

  bool get isOut => remaining <= 0;

  ChatConversationState copyWith({
    BlocStatus? status,
    List<ChatMessageModel>? messages,
    bool? sending,
    int? remaining,
    int? total,
    String? error,
  }) {
    return ChatConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
      error: error ?? this.error,
    );
  }
}