/// Tham số truyền vào màn hình báo động khẩn cấp SOS.
class SosAlertArgs {
  const SosAlertArgs({
    this.deviceName = 'Nút SOS Khẩn Cấp',
    this.batteryLevel = 100,
    this.triggeredAt,
    this.emergencyPhone = '115',
    this.latitude = 21.0285,
    this.longitude = 105.8542,
  });

  /// Tên thiết bị gây báo động.
  final String deviceName;

  /// Mức pin của thiết bị (%).
  final int batteryLevel;

  /// Thời điểm báo động được kích hoạt.
  final DateTime? triggeredAt;

  /// Số điện thoại khẩn cấp mặc định (người dùng có thể đổi khi gọi).
  final String emergencyPhone;

  /// Vĩ độ vị trí thiết bị.
  final double latitude;

  /// Kinh độ vị trí thiết bị.
  final double longitude;

  /// Chuyển đổi thành Map để truyền qua payload của notification.
  Map<String, dynamic> toJson() => {
    'deviceName': deviceName,
    'batteryLevel': batteryLevel.toString(),
    'triggeredAt': triggeredAt?.toIso8601String(),
    'emergencyPhone': emergencyPhone,
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
  };

  /// Parse từ payload JSON của local notification.
  static SosAlertArgs? fromJson(Map<String, dynamic> json) => SosAlertArgs(
    deviceName: json['deviceName']?.toString() ?? 'Nút SOS Khẩn Cấp',
    batteryLevel: int.tryParse(json['batteryLevel']?.toString() ?? '') ?? 100,
    triggeredAt:
        json['triggeredAt'] != null
            ? DateTime.tryParse(json['triggeredAt'].toString())
            : null,
    emergencyPhone: json['emergencyPhone']?.toString() ?? '115',
    latitude:
        double.tryParse(json['latitude']?.toString() ?? '') ?? 21.0285,
    longitude:
        double.tryParse(json['longitude']?.toString() ?? '') ?? 105.8542,
  );

  /// Parse từ `data` của FCM. Trả về `null` nếu không phải tin nhắn SOS.
  static SosAlertArgs? fromFcmData(Map<String, dynamic>? data) {
    if (data == null || data['type'] != 'sos_alert') return null;
    final deviceId = data['deviceId'];
    if (deviceId == null || deviceId.toString().isEmpty) return null;

    return SosAlertArgs(
      deviceName: data['deviceName']?.toString() ?? 'Nút SOS Khẩn Cấp',
      batteryLevel: int.tryParse(data['batteryLevel']?.toString() ?? '') ?? 100,
      triggeredAt:
          data['triggeredAt'] != null
              ? DateTime.tryParse(data['triggeredAt'].toString())
              : null,
      emergencyPhone: data['emergencyPhone']?.toString() ?? '115',
      latitude: double.tryParse(data['latitude']?.toString() ?? '') ?? 21.0285,
      longitude: double.tryParse(data['longitude']?.toString() ?? '') ?? 105.8542,
    );
  }
}