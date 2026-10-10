/// Tham số truyền vào màn hình báo động khẩn cấp SOS.
class SosAlertArgs {
  const SosAlertArgs({
    this.alertId,
    this.deviceName = 'Nút SOS Khẩn Cấp',
    this.batteryLevel = 100,
    this.triggeredAt,
    this.emergencyPhone = '115',
  });

  /// ID bản ghi cảnh báo trong `sos_alerts` (dùng để xác nhận đã xử lý).
  final String? alertId;

  /// Tên thiết bị gây báo động.
  final String deviceName;

  /// Mức pin của thiết bị (%).
  final int batteryLevel;

  /// Thời điểm báo động được kích hoạt.
  final DateTime? triggeredAt;

  /// Số điện thoại khẩn cấp mặc định (người dùng có thể đổi khi gọi).
  final String emergencyPhone;

  /// Chuyển đổi thành Map để truyền qua payload của notification.
  Map<String, dynamic> toJson() => {
    'alertId': alertId,
    'deviceName': deviceName,
    'batteryLevel': batteryLevel.toString(),
    'triggeredAt': triggeredAt?.toIso8601String(),
    'emergencyPhone': emergencyPhone,
  };

  /// Parse từ payload JSON của local notification.
  static SosAlertArgs? fromJson(Map<String, dynamic> json) => SosAlertArgs(
    alertId: json['alertId']?.toString(),
    deviceName: json['deviceName']?.toString() ?? 'Nút SOS Khẩn Cấp',
    batteryLevel: int.tryParse(json['batteryLevel']?.toString() ?? '') ?? 100,
    triggeredAt: json['triggeredAt'] != null
        ? DateTime.tryParse(json['triggeredAt'].toString())
        : null,
    emergencyPhone: json['emergencyPhone']?.toString() ?? '115',
  );

  /// Parse từ `data` của FCM. Trả về `null` nếu không phải tin nhắn SOS.
  static SosAlertArgs? fromFcmData(Map<String, dynamic>? data) {
    if (data == null || data['type'] != 'sos_alert') return null;
    final deviceId = data['deviceId'];
    if (deviceId == null || deviceId.toString().isEmpty) return null;

    return SosAlertArgs(
      alertId: data['alertId']?.toString(),
      deviceName: data['deviceName']?.toString() ?? 'Nút SOS Khẩn Cấp',
      batteryLevel: int.tryParse(data['batteryLevel']?.toString() ?? '') ?? 100,
      triggeredAt: data['triggeredAt'] != null
          ? DateTime.tryParse(data['triggeredAt'].toString())
          : null,
      emergencyPhone: data['emergencyPhone']?.toString() ?? '115',
    );
  }
}
