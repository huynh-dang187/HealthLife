import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Vai trò người gửi tin nhắn trong phiên.
enum ChatMessageRole { user, assistant }

/// Tin nhắn trong `users/{uid}/chat_sessions/{sessionId}/messages/{id}`.
@immutable
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final ChatMessageRole role;
  final String content;
  final DateTime createdAt;

  factory ChatMessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = data['role'] as String? ?? 'user';
    return ChatMessageModel(
      id: doc.id,
      role: role == 'model' ? ChatMessageRole.assistant : ChatMessageRole.user,
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}