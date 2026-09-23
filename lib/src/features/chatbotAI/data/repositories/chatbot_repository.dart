import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:healthlife/src/features/chatbotAI/data/models/chat_message_model.dart';
import 'package:healthlife/src/features/chatbotAI/data/models/chat_session_model.dart';

/// Kết quả từ `chatbotMessage` (callable function).
class ChatbotReplyResult {
  const ChatbotReplyResult({
    required this.sessionId,
    required this.reply,
    required this.remaining,
    required this.total,
  });

  final String sessionId;
  final String reply;
  final int remaining;
  final int total;
}

/// Usage (quota ngày) đọc từ `users/{uid}.chatbotUsage`.
class ChatbotUsage {
  const ChatbotUsage({required this.remaining, required this.total});

  final int remaining;
  final int total;

  factory ChatbotUsage.fromJson(Map<String, dynamic> json) {
    final quota = (json['quota'] as num?)?.toInt() ?? 50;
    final used = (json['used'] as num?)?.toInt() ?? 0;
    return ChatbotUsage(remaining: quota - used, total: quota);
  }
}

/// Gọi Cloud Function `chatbotMessage`/`chatbotGenerateTitle` qua HTTP callable
/// (app không dùng firebase_functions SDK) và CRUD phiên trên Firestore.
class ChatbotRepository {
  ChatbotRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    String? region,
    String? projectId,
    http.Client? client,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _region = region ?? 'us-central1',
       _projectId = projectId ?? 'healthlife-e89fd',
       _client = client ?? http.Client();

  static const _defaultQuota = 50;
  static const _defaultTotal = 50;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final String _region;
  final String _projectId;
  final http.Client _client;

  String get _baseUrl => 'https://$_region-$_projectId.cloudfunctions.net';

  Future<String?> _idToken() async {
    final user = _auth.currentUser;
    return user?.getIdToken();
  }

  /// Gọi một callable function, tự mang token Firebase Auth.
  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final token = await _idToken();
    if (token == null) {
      throw StateError('Bạn cần đăng nhập để dùng BiBi.');
    }

    final response = await _client
        .post(
          Uri.parse('$_baseUrl/$name'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'data': data}),
        )
        .timeout(const Duration(seconds: 90));

    debugPrint(
      '[ChatbotRepo] $name => ${response.statusCode}: ${response.body}',
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final msg =
          (decoded['error'] as Map<String, dynamic>?)?['message'] as String? ??
          'Lỗi kết nối BiBi (${response.statusCode})';
      throw StateError(msg);
    }
    final result = decoded['result'];
    if (result is Map<String, dynamic>) return result;
    throw StateError('Phản hồi không hợp lệ từ BiBi.');
  }

  /// Gửi tin nhắn, nhận reply + usage mới. Truyền `sessionId` null để tạo phiên mới.
  Future<ChatbotReplyResult> sendMessage(
    String message, {
    String? sessionId,
  }) async {
    final result = await _call('chatbotMessage', {
      'message': message,
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
    });
    final usage = result['usage'] as Map<String, dynamic>? ?? const {};
    return ChatbotReplyResult(
      sessionId: result['sessionId'] as String,
      reply: result['reply'] as String,
      remaining: (usage['remaining'] as num?)?.toInt() ?? _defaultQuota,
      total: (usage['quota'] as num?)?.toInt() ?? _defaultTotal,
    );
  }

  /// Đặt tên phiên từ tin nhắn đầu tiên.
  Future<String> generateTitle(String sessionId, String firstMessage) async {
    final result = await _call('chatbotGenerateTitle', {
      'sessionId': sessionId,
      'message': firstMessage,
    });
    return result['title'] as String? ?? 'Cuộc trò chuyện';
  }

  // ---------- Firestore CRUD ----------

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _sessions() {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Bạn cần đăng nhập để dùng BiBi.');
    }
    return _firestore.collection('users').doc(uid).collection('chat_sessions');
  }

  Query<Map<String, dynamic>> _messagesQuery(String sessionId) {
    return _sessions().doc(sessionId).collection('messages');
  }

  /// Stream danh sách phiên, sắp theo updatedAt giảm dần.
  Stream<List<ChatSessionModel>> watchSessions() {
    return _sessions()
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(ChatSessionModel.fromDoc).toList(),
        );
  }

  /// Stream tin nhắn của một phiên, theo thứ tự tăng dần.
  Stream<List<ChatMessageModel>> watchMessages(String sessionId) {
    return _messagesQuery(sessionId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map(ChatMessageModel.fromDoc).toList(),
        );
  }

  Future<ChatSessionModel?> fetchSession(String sessionId) async {
    final doc = await _sessions().doc(sessionId).get();
    if (!doc.exists) return null;
    return ChatSessionModel.fromDoc(doc);
  }

  /// Đổi tên phiên.
  Future<void> renameSession(String sessionId, String newTitle) async {
    await _sessions().doc(sessionId).update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pin/unpin phiên.
  Future<void> togglePin(String sessionId, bool pinned) async {
    await _sessions().doc(sessionId).update({
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xoá phiên (kèm subcollection messages).
  Future<void> deleteSession(String sessionId) async {
    await _deleteRecursively(_messagesQuery(sessionId));
    await _sessions().doc(sessionId).delete();
  }

  /// Xoá toàn bộ subcollection (từng doc một, batch mỗi lần 400).
  Future<void> _deleteRecursively(Query<Map<String, dynamic>> query) async {
    while (true) {
      final snap = await query.limit(400).get();
      if (snap.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Usage hiện tại từ `users/{uid}.chatbotUsage`.
  Future<ChatbotUsage> fetchUsage() async {
    final uid = _uid;
    if (uid == null) {
      return const ChatbotUsage(remaining: _defaultQuota, total: _defaultTotal);
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final usage = doc.data()?['chatbotUsage'] as Map<String, dynamic>? ?? {};
      return ChatbotUsage.fromJson(usage);
    } catch (e) {
      debugPrint('[ChatbotRepo] fetchUsage lỗi: $e');
      return const ChatbotUsage(remaining: _defaultQuota, total: _defaultTotal);
    }
  }
}
