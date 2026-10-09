import 'package:cloud_firestore/cloud_firestore.dart';

/// Thông tin một thiết bị SOS (doc trong `sos_devices/{deviceId}`).
class SosDevice {
  final String deviceId;
  final String deviceName;
  final int batteryLevel;
  final bool isOnline;
  final DateTime? lastTriggeredAt;
  final List<String> recipientIds;
  final String? emergencyPhone;
  final double? latitude;
  final double? longitude;

  const SosDevice({
    required this.deviceId,
    required this.deviceName,
    required this.batteryLevel,
    required this.isOnline,
    required this.recipientIds,
    this.lastTriggeredAt,
    this.emergencyPhone,
    this.latitude,
    this.longitude,
  });

  bool containsUser(String uid) => recipientIds.contains(uid);

  factory SosDevice.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final ts = data['lastTriggeredAt'];

    return SosDevice(
      deviceId: snapshot.id,
      deviceName: data['deviceName']?.toString() ?? 'Nút SOS Khẩn Cấp',
      batteryLevel: int.tryParse(data['batteryLevel']?.toString() ?? '') ?? 100,
      isOnline: data['isOnline'] == true,
      lastTriggeredAt: ts is Timestamp ? ts.toDate() : null,
      recipientIds: List<String>.from(data['recipientIds'] ?? const []),
      emergencyPhone: data['emergencyPhone']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}