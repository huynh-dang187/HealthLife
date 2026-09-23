import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Phiên trò chuyện BiBi, lưu tại `users/{uid}/chat_sessions/{sessionId}`.
@immutable
class ChatSessionModel {
  const ChatSessionModel({
    required this.id,
    required this.title,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessagePreview,
    this.usageCount = 0,
  });

  final String id;
  final String title;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessagePreview;
  final int usageCount;

  ChatSessionModel copyWith({
    String? title,
    bool? pinned,
    DateTime? updatedAt,
    String? lastMessagePreview,
    int? usageCount,
  }) {
    return ChatSessionModel(
      id: id,
      title: title ?? this.title,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  factory ChatSessionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSessionModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Cuộc trò chuyện mới',
      pinned: data['pinned'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessagePreview: data['lastMessagePreview'] as String?,
      usageCount: (data['usageCount'] as num?)?.toInt() ?? 0,
    );
  }
}
