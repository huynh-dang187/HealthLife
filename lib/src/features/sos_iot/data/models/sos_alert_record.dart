import 'package:cloud_firestore/cloud_firestore.dart';

/// Một bản ghi cảnh báo SOS (doc trong `sos_alerts/{alertId}`).
class SosAlertRecord {
  final String alertId;
  final String deviceId;
  final String deviceName;
  final DateTime triggeredAt;
  final String status;
  final int batteryLevel;

  bool get isAcknowledged => status == 'acknowledged';

  const SosAlertRecord({
    required this.alertId,
    required this.deviceId,
    required this.deviceName,
    required this.triggeredAt,
    required this.status,
    required this.batteryLevel,
  });

  factory SosAlertRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final ts = data['triggeredAt'];

    return SosAlertRecord(
      alertId: snapshot.id,
      deviceId: data['deviceId']?.toString() ?? '',
      deviceName: data['deviceName']?.toString() ?? 'Nút SOS',
      triggeredAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.tryParse(data['triggeredAt']?.toString() ?? '') ??
                DateTime.now(),
      status: data['status']?.toString() ?? 'pending',
      batteryLevel: int.tryParse(data['batteryLevel']?.toString() ?? '') ?? 100,
    );
  }
}