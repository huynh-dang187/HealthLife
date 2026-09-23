import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/chatbotAI/data/repositories/chatbot_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'chat_conversation_state.dart';

/// Quản lý phiên trò chuyện đang mở: stream tin nhắn, gửi tin, số lượt còn lại.
class ChatConversationCubit extends Cubit<ChatConversationState> {
  ChatConversationCubit(this._repository)
    : super(const ChatConversationState()) {
    _loadUsage();
  }

  final ChatbotRepository _repository;
  StreamSubscription? _messagesSub;
  String? _sessionId;
  bool _generatedTitle = false;

  String? get sessionId => _sessionId;

  Future<void> _loadUsage() async {
    final usage = await _repository.fetchUsage();
    emit(state.copyWith(remaining: usage.remaining, total: usage.total));
  }

  /// Bắt đầu phiên mới (đóng stream cũ, reset danh sách tin).
  void startNewSession() {
    _messagesSub?.cancel();
    _messagesSub = null;
    _sessionId = null;
    _generatedTitle = false;
    emit(
      state.copyWith(
        status: BlocStatus.success,
        messages: const [],
        sending: false,
        error: null,
      ),
    );
  }

  /// Mở một phiên có sẵn từ lịch sử.
  void openSession(String sessionId) {
    _messagesSub?.cancel();
    _sessionId = sessionId;
    _generatedTitle = true; // đã có tên, không auto-title lại
    emit(state.copyWith(status: BlocStatus.loading, messages: const []));
    _messagesSub = _repository
        .watchMessages(sessionId)
        .listen(
          (messages) {
            emit(
              state.copyWith(
                status: BlocStatus.success,
                messages: messages,
                error: null,
              ),
            );
          },
          onError: (e) {
            emit(state.copyWith(status: BlocStatus.failure, error: '$e'));
          },
        );
  }

  /// Gửi một tin nhắn. Nếu là tin đầu tiên của phiên mới thì auto-title.
  Future<void> sendMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty || state.sending) return;

    emit(state.copyWith(sending: true, error: null));
    try {
      final result = await _repository.sendMessage(
        text,
        sessionId: _sessionId,
      );
      final isFirst = _sessionId == null;
      _sessionId = result.sessionId;
      emit(
        state.copyWith(
          sending: false,
          remaining: result.remaining,
          total: result.total,
        ),
      );

      // Gắn stream tin nhắn cho phiên (mới hoặc vừa tạo).
      _messagesSub?.cancel();
      _messagesSub = _repository.watchMessages(result.sessionId).listen((
        messages,
      ) {
        emit(state.copyWith(messages: messages, error: null));
      });

      // Tự đặt tên phiên sau tin đầu tiên.
      if (isFirst && !_generatedTitle) {
        _generatedTitle = true;
        unawaited(
          _repository.generateTitle(result.sessionId, text).catchError((_) {
            // bỏ qua lỗi đặt tên, không chặn chat
            return 'Cuộc trò chuyện';
          }),
        );
      }
    } catch (e) {
      emit(state.copyWith(sending: false, error: '$e'));
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
