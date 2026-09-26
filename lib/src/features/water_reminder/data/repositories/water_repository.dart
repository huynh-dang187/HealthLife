import '../datasources/water_local_datasource.dart';
import '../models/water_log_model.dart';
import '../models/water_settings_model.dart';

class WaterRepository {
  final WaterLocalDataSource _localDataSource;

  WaterRepository({WaterLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? WaterLocalDataSource();

  /// Thêm lịch sử uống nước
  Future<void> addWaterLog(int amount) async {
    final now = DateTime.now();
    final log = WaterLogModel(
      id: now.millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: now,
    );
    await _localDataSource.addWaterLog(log);
  }

  /// Xóa lịch sử uống nước
  Future<void> deleteWaterLog(String id) async {
    await _localDataSource.deleteWaterLog(id);
  }

  /// Lấy danh sách uống nước hôm nay (lọc theo dateString múi giờ VN UTC+7)
  Future<List<WaterLogModel>> getTodayLogs() async {
    final todayDateString = WaterLogModel.getTodayVietnamDateString();
    return await _localDataSource.getTodayLogs(todayDateString);
  }

  /// Tính tổng lượng nước uống hôm nay
  Future<int> getTodayTotalIntake() async {
    final logs = await getTodayLogs();
    return logs.fold<int>(0, (sum, item) => sum + item.amount);
  }

  /// Lấy cài đặt mục tiêu & nhắc nhở
  Future<WaterSettingsModel> getSettings() async {
    return await _localDataSource.getSettings();
  }

  /// Cập nhật mục tiêu ngày
  Future<void> updateGoal(int newGoal) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(dailyGoal: newGoal);
    await _localDataSource.saveSettings(updatedSettings);
  }

  /// Cập nhật cài đặt thông báo & nhắc nhở
  Future<void> updateSettings(WaterSettingsModel settings) async {
    await _localDataSource.saveSettings(settings);
  }
}
