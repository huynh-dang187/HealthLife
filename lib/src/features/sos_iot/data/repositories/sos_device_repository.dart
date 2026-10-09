import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/sos_alert_record.dart';
import '../models/sos_device.dart';
import '../models/sos_user_info.dart';

/// Kết quả của thao tác ghép nối thiết bị.
enum SosPairStatus {
  /// Đã nối thành công (tạo mới hoặc thêm mình vào người nhận).
  paired,

  /// Mã hợp lệ nhưng user này đã nối rồi.
  alreadyJoined,

  /// Thiết bị đã đạt tối đa 3 người nhận.
  deviceFull,

  /// Chưa tồn tại thiết bị với mã này (cần người dùng xác nhận tạo mới).
  notFound,
}

/// Truy cập `sos_devices/{deviceId}` + `sos_alerts` + tra cứu `users`.
class SosDeviceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int maxRecipients = 3;
  static const int maxDeviceCodeLength = 32;

  DocumentReference<Map<String, dynamic>> _deviceRef(String deviceId) =>
      _db.collection('sos_devices').doc(deviceId);

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Chuẩn hoá mã thiết bị: bỏ khoảng trắng (giữ nguyên chữ hoa/thường,
  /// vì doc ID trong Firestore phân biệt chữ hoa chữ thường).
  static String normalizeDeviceCode(String input) => input.trim();

  /// Mã hợp lệ: 1–32 ký tự, chỉ gồm chữ hoa / thường / số / `-` / `_`.
  static bool isValidDeviceCode(String raw) {
    final code = normalizeDeviceCode(raw);
    return code.isNotEmpty &&
        code.length <= 32 &&
        RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(code);
  }

  /// Chuẩn hoá SĐT về dạng E.164 (+84...); trả về `null` nếu rỗng.
  static String? normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('84')) return '+$digits';
    if (digits.startsWith('0')) return '+84${digits.substring(1)}';
    return '+$digits';
  }

  Future<SosDevice?> getDevice(String deviceId) async {
    final snap = await _deviceRef(deviceId).get();
    if (!snap.exists) return null;
    return SosDevice.fromSnapshot(snap);
  }

  /// Stream realtime doc thiết bị (bản đồ thông tin hub).
  Stream<SosDevice?> watchDevice(String deviceId) =>
      _deviceRef(deviceId).snapshots().map(
        (s) => s.exists ? SosDevice.fromSnapshot(s) : null,
      );

  /// Stream các thiết bị mà user này đang kết nối (nằm trong recipientIds).
  Stream<List<SosDevice>> watchMyDevices(String uid) => _db
      .collection('sos_devices')
      .where('recipientIds', arrayContains: uid)
      .snapshots()
      .map(
        (q) =>
            q.docs.where((d) => d.exists).map(SosDevice.fromSnapshot).toList(),
      );

  /// Ghép nối: tạo doc nếu chưa có, ngược lại thêm mình vào người nhận (≤3).
  /// Throw [FormatException] nếu mã không hợp lệ.
  ///
  /// Nếu thiết bị chưa tồn tại và [createIfMissing] = false thì trả về
  /// [SosPairStatus.notFound] để UI hỏi xác nhận trước khi tạo mới (tránh
  /// tạo "thiết bị ma" do gõ nhầm mã).
  Future<SosPairStatus> pair(
    String rawCode, {
    bool createIfMissing = false,
  }) async {
    if (!isValidDeviceCode(rawCode)) {
      throw const FormatException('invalid_device_code');
    }
    final deviceId = normalizeDeviceCode(rawCode);
    final uid = _uid;
    final ref = _deviceRef(deviceId);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        if (!createIfMissing) return SosPairStatus.notFound;
        tx.set(ref, {
          'deviceName': 'Nút SOS $deviceId',
          'recipientIds': [uid],
          'batteryLevel': 100,
          'isOnline': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return SosPairStatus.paired;
      }

      final recipients = List<String>.from(
        snap.data()?['recipientIds'] ?? const [],
      );
      if (recipients.contains(uid)) return SosPairStatus.alreadyJoined;
      if (recipients.length >= maxRecipients) return SosPairStatus.deviceFull;

      tx.update(ref, {
        'recipientIds': [...recipients, uid],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return SosPairStatus.paired;
    });
  }

  /// Mời thêm một user vào danh sách người nhận (chưa đủ 3, chưa có sẵn).
  Future<void> addRecipient(String deviceId, String targetUid) async {
    final ref = _deviceRef(deviceId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final recipients = List<String>.from(
        snap.data()?['recipientIds'] ?? const [],
      );
      if (recipients.contains(targetUid)) return;
      if (recipients.length >= maxRecipients) {
        throw StateError('device_full');
      }
      tx.update(ref, {
        'recipientIds': [...recipients, targetUid],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Rời nhóm: gỡ chính mình khỏi danh sách người nhận.
  Future<void> leave(String deviceId) async {
    await _removeRecipient(deviceId, _uid);
  }

  /// Xoá một thành viên khỏi danh sách người nhận (chỉ người đang kết nối).
  Future<void> removeRecipient(String deviceId, String targetUid) async {
    await _removeRecipient(deviceId, targetUid);
  }

  Future<void> _removeRecipient(String deviceId, String targetUid) async {
    final ref = _deviceRef(deviceId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final recipients = List<String>.from(
        snap.data()?['recipientIds'] ?? const [],
      );
      if (!recipients.contains(targetUid)) return;
      final remaining = recipients.where((u) => u != targetUid).toList();
      if (remaining.isEmpty) {
        tx.delete(ref);
        return;
      }
      tx.update(ref, {
        'recipientIds': remaining,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Lịch sử cảnh báo của thiết bị (50 bản mới nhất, realtime).
  Stream<List<SosAlertRecord>> watchAlerts(String deviceId) => _db
      .collection('sos_alerts')
      .where('deviceId', isEqualTo: deviceId)
      .orderBy('triggeredAt', descending: true)
      .limit(50)
      .snapshots()
      .map(
        (q) => q.docs.map(SosAlertRecord.fromSnapshot).toList(),
      );

  /// Đánh dấu cảnh báo đã được xử lý (người nhận xác nhận).
  Future<void> acknowledgeAlert(String alertId) async {
    await _db.collection('sos_alerts').doc(alertId).update({
      'status': 'acknowledged',
      'acknowledgedBy': _uid,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sửa thông tin thiết bị (tên hiển thị / SĐT khẩn cấp). Không đổi người nhận.
  Future<void> updateDeviceSettings(
    String deviceId, {
    required String deviceName,
    String? emergencyPhone,
  }) async {
    await _deviceRef(deviceId).update({
      'deviceName': deviceName.trim(),
      'emergencyPhone': emergencyPhone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<SosUserInfo?> fetchUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return SosUserInfo.fromSnapshot(snap);
  }

  /// Tìm user theo SĐT (dạng E.164). Trả `null` nếu không có.
  Future<SosUserInfo?> searchUserByPhone(String rawPhone) async {
    final phone = normalizePhone(rawPhone);
    if (phone == null) return null;
    final query = await _db
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return SosUserInfo.fromSnapshot(query.docs.first);
  }
}
