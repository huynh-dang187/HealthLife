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
}