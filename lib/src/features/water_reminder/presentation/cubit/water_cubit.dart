import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/water_settings_model.dart';
import '../../data/repositories/water_repository.dart';
import '../../services/water_notification_service.dart';
import 'water_state.dart';

class WaterCubit extends Cubit<WaterState> {
  final WaterRepository _repository;
  final WaterNotificationService _notificationService;

  WaterCubit({
    WaterRepository? repository,
    WaterNotificationService? notificationService,
  })  : _repository = repository ?? WaterRepository(),
        _notificationService =
            notificationService ?? WaterNotificationService(),
        super(const WaterState());

  /// Tải dữ liệu ban đầu
  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final settings = await _repository.getSettings();
      final todayLogs = await _repository.getTodayLogs();
      final currentIntake = await _repository.getTodayTotalIntake();

      emit(state.copyWith(
        isLoading: false,
        dailyGoal: settings.dailyGoal,
        currentIntake: currentIntake,
        todayLogs: todayLogs,
        settings: settings,
      ));

      _syncNotificationSchedule(settings: settings, intake: currentIntake);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu: ${e.toString()}',
      ));
    }
  }

  /// Thêm lượng nước uống
  Future<void> addWater(int amount) async {
    if (amount <= 0) return;
    try {
      await _repository.addWaterLog(amount);
      final todayLogs = await _repository.getTodayLogs();
      final currentIntake = await _repository.getTodayTotalIntake();

      emit(state.copyWith(
        currentIntake: currentIntake,
        todayLogs: todayLogs,
      ));

      // Quy tắc nghiệp vụ: Nếu đạt/vượt mục tiêu -> ngưng nhắc nhở trong ngày
      if (currentIntake >= state.dailyGoal) {
        await _notificationService.cancelAllReminders();
      } else if (state.settings.isReminderEnabled) {
        _syncNotificationSchedule(settings: state.settings, intake: currentIntake);
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi khi thêm lượng nước: ${e.toString()}',
      ));
    }
  }

  /// Xóa nhật ký uống nước
  Future<void> deleteWaterLog(String id) async {
    try {
      await _repository.deleteWaterLog(id);
      final todayLogs = await _repository.getTodayLogs();
      final currentIntake = await _repository.getTodayTotalIntake();

      emit(state.copyWith(
        currentIntake: currentIntake,
        todayLogs: todayLogs,
      ));

      _syncNotificationSchedule(settings: state.settings, intake: currentIntake);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi khi xóa nhật ký: ${e.toString()}',
      ));
    }
  }

  /// Cập nhật mục tiêu ngày
  Future<void> updateDailyGoal(int goal) async {
    if (goal <= 0) return;
    try {
      await _repository.updateGoal(goal);
      final updatedSettings = state.settings.copyWith(dailyGoal: goal);

      emit(state.copyWith(
        dailyGoal: goal,
        settings: updatedSettings,
      ));

      _syncNotificationSchedule(settings: updatedSettings, intake: state.currentIntake);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi khi cập nhật mục tiêu: ${e.toString()}',
      ));
    }
  }

  /// Bật/Tắt nhắc nhở
  Future<void> toggleReminder(bool isEnabled) async {
    try {
      final updatedSettings = state.settings.copyWith(isReminderEnabled: isEnabled);
      await _repository.updateSettings(updatedSettings);

      emit(state.copyWith(settings: updatedSettings));

      _syncNotificationSchedule(settings: updatedSettings, intake: state.currentIntake);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi khi cài đặt nhắc nhở: ${e.toString()}',
      ));
    }
  }

  /// Cập nhật lịch nhắc nhở
  Future<void> updateReminderSchedule({
    required String startTime,
    required String endTime,
    required int intervalHours,
  }) async {
    try {
      final updatedSettings = state.settings.copyWith(
        startTime: startTime,
        endTime: endTime,
        intervalHours: intervalHours,
      );
      await _repository.updateSettings(updatedSettings);

      emit(state.copyWith(settings: updatedSettings));

      _syncNotificationSchedule(settings: updatedSettings, intake: state.currentIntake);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi khi cập nhật lịch nhắc: ${e.toString()}',
      ));
    }
  }

  /// Đồng bộ lịch thông báo dựa trên cài đặt và lượng nước đã uống
  void _syncNotificationSchedule({
    required WaterSettingsModel settings,
    required int intake,
  }) {
    if (!settings.isReminderEnabled || intake >= settings.dailyGoal) {
      _notificationService.cancelAllReminders();
    } else {
      _notificationService.schedulePeriodicReminders(
        intervalHours: settings.intervalHours,
        startTime: settings.startTime,
        endTime: settings.endTime,
      );
    }
  }
}
