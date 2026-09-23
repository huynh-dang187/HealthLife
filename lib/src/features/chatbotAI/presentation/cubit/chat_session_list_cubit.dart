import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/chatbotAI/data/repositories/chatbot_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'chat_session_list_state.dart';

/// Quản lý danh sách phiên lịch sử (stream Firestore) + rename/delete/pin.
class ChatSessionListCubit extends Cubit<ChatSessionListState> {
  ChatSessionListCubit(this._repository)
      : super(const ChatSessionListState()) {
    _sub = _repository.watchSessions().listen(
      (sessions) {
        emit(
          state.copyWith(status: BlocStatus.success, sessions: sessions),
        );
      },
      onError: (e) {
        emit(state.copyWith(status: BlocStatus.failure, error: '$e'));
      },
    );
  }

  final ChatbotRepository _repository;
  StreamSubscription? _sub;

  Future<void> rename(String sessionId, String newTitle) async {
    final title = newTitle.trim();
    if (title.isEmpty) return;
    try {
      await _repository.renameSession(sessionId, title);
    } catch (e) {
      emit(state.copyWith(error: '$e'));
    }
  }

  Future<void> togglePin(String sessionId, bool pinned) async {
    try {
      await _repository.togglePin(sessionId, pinned);
    } catch (e) {
      emit(state.copyWith(error: '$e'));
    }
  }

  Future<void> delete(String sessionId) async {
    final current = state.sessions;
    final removedIndex = current.indexWhere((s) => s.id == sessionId);
    if (removedIndex == -1) return;

    // Xoá lạc quan trước cho UI mượt, rollback nếu lỗi.
    final optimistic = [...current]..removeAt(removedIndex);
    emit(state.copyWith(sessions: optimistic));
    try {
      await _repository.deleteSession(sessionId);
    } catch (e) {
      emit(
        state.copyWith(sessions: current, error: 'Không xoá được phiên: $e'),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}