import 'package:cloud_firestore/cloud_firestore.dart';

/// Thông tin tối thiểu một user để hiển thị trong danh sách người nhận SOS.
class SosUserInfo {
  final String uid;
  final String displayName;
  final String? phone;

  const SosUserInfo({
    required this.uid,
    required this.displayName,
    this.phone,
  });

  factory SosUserInfo.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};

    return SosUserInfo(
      uid: snapshot.id,
      displayName: data['displayName']?.toString() ?? 'Người dùng',
      phone: data['phone']?.toString(),
    );
  }
}