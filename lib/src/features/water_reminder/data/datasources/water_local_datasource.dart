import 'package:hive_ce/hive.dart';
import '../models/water_log_model.dart';
import '../models/water_settings_model.dart';

class WaterLocalDataSource {
  static const String logsBoxName = 'water_logs_box';
  static const String settingsBoxName = 'water_settings_box';
  static const String settingsKey = 'water_settings_key';

  Future<Box> _openLogsBox() async {
    if (Hive.isBoxOpen(logsBoxName)) {
      return Hive.box(logsBoxName);
    }
    return await Hive.openBox(logsBoxName);
  }

  Future<Box> _openSettingsBox() async {
    if (Hive.isBoxOpen(settingsBoxName)) {
      return Hive.box(settingsBoxName);
    }
    return await Hive.openBox(settingsBoxName);
  }

  /// Thêm lịch sử uống nước vào Hive
  Future<void> addWaterLog(WaterLogModel log) async {
    final box = await _openLogsBox();
    await box.put(log.id, log.toMap());
  }

  /// Xóa lịch sử uống nước theo id
  Future<void> deleteWaterLog(String id) async {
    final box = await _openLogsBox();
    await box.delete(id);
  }

  /// Lấy danh sách uống nước hôm nay lọc theo dateString (múi giờ VN)
  Future<List<WaterLogModel>> getTodayLogs(String todayDateString) async {
    final box = await _openLogsBox();
    final List<WaterLogModel> logs = [];

    for (final rawValue in box.values) {
      if (rawValue is Map) {
        final log = WaterLogModel.fromMap(rawValue);
        if (log.dateString == todayDateString) {
          logs.add(log);
        }
      } else if (rawValue is WaterLogModel) {
        if (rawValue.dateString == todayDateString) {
          logs.add(rawValue);
        }
      }
    }

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  /// Lấy cài đặt ứng dụng
  Future<WaterSettingsModel> getSettings() async {
    final box = await _openSettingsBox();
    final rawValue = box.get(settingsKey);

    if (rawValue == null) {
      return const WaterSettingsModel();
    }

    if (rawValue is Map) {
      return WaterSettingsModel.fromMap(rawValue);
    } else if (rawValue is WaterSettingsModel) {
      return rawValue;
    }

    return const WaterSettingsModel();
  }

  /// Lưu cài đặt ứng dụng
  Future<void> saveSettings(WaterSettingsModel settings) async {
    final box = await _openSettingsBox();
    await box.put(settingsKey, settings.toMap());
  }
}
