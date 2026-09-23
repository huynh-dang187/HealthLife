import 'package:healthlife/src/features/chatbotAI/data/models/chat_session_model.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

/// Trạng thái danh sách phiên trong drawer lịch sử.
final class ChatSessionListState {
  const ChatSessionListState({
    this.status = BlocStatus.initial,
    this.sessions = const [],
    this.error,
  });

  final BlocStatus status;
  final List<ChatSessionModel> sessions;
  final String? error;

  ChatSessionListState copyWith({
    BlocStatus? status,
    List<ChatSessionModel>? sessions,
    String? error,
  }) {
    return ChatSessionListState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      error: error ?? this.error,
    );
  }
}
