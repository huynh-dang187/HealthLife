import 'package:equatable/equatable.dart';

class WaterSettingsModel extends Equatable {
  final int dailyGoal; // Mặc định 2000 ml
  final bool isReminderEnabled; // Mặc định true
  final int intervalHours; // Mặc định 2 giờ
  final String startTime; // Mặc định "07:00"
  final String endTime; // Mặc định "22:00"

  const WaterSettingsModel({
    this.dailyGoal = 2000,
    this.isReminderEnabled = true,
    this.intervalHours = 2,
    this.startTime = "07:00",
    this.endTime = "22:00",
  });

  WaterSettingsModel copyWith({
    int? dailyGoal,
    bool? isReminderEnabled,
    int? intervalHours,
    String? startTime,
    String? endTime,
  }) {
    return WaterSettingsModel(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      intervalHours: intervalHours ?? this.intervalHours,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyGoal': dailyGoal,
      'isReminderEnabled': isReminderEnabled,
      'intervalHours': intervalHours,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory WaterSettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return WaterSettingsModel(
      dailyGoal: (map['dailyGoal'] as num?)?.toInt() ?? 2000,
      isReminderEnabled: map['isReminderEnabled'] as bool? ?? true,
      intervalHours: (map['intervalHours'] as num?)?.toInt() ?? 2,
      startTime: map['startTime'] as String? ?? "07:00",
      endTime: map['endTime'] as String? ?? "22:00",
    );
  }

  @override
  List<Object?> get props => [
        dailyGoal,
        isReminderEnabled,
        intervalHours,
        startTime,
        endTime,
      ];
}
