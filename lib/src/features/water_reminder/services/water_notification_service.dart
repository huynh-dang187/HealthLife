import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class WaterNotificationService {
  static final WaterNotificationService _instance =
  WaterNotificationService._internal();

  factory WaterNotificationService() => _instance;

  WaterNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Khởi tạo dịch vụ thông báo
  Future<void> initNotification() async {
    if (_isInitialized) return;
    try {
      tz_data.initializeTimeZones();

      try {
        tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      await _notificationsPlugin.initialize(
        settings: settings,
      );

      await requestPermissions();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Lỗi khởi tạo Notification: $e');
    }
  }

  /// Xin quyền hiển thị thông báo & báo thức chính xác trên Android/iOS
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      final iosImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Hủy toàn bộ thông báo nhắc nhở
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Lỗi hủy notification: $e');
    }
  }

  /// Đặt lịch nhắc nhở định kỳ từ startTime đến endTime theo intervalHours
  Future<void> schedulePeriodicReminders({
    required int intervalHours,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await initNotification();
      await cancelAllReminders();

      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      if (startParts.length < 2 || endParts.length < 2) return;

      final startHour = int.tryParse(startParts[0]) ?? 7;
      final startMinute = int.tryParse(startParts[1]) ?? 0;
      final endHour = int.tryParse(endParts[0]) ?? 22;
      final endMinute = int.tryParse(endParts[1]) ?? 0;

      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;
      final intervalMinutes = (intervalHours <= 0 ? 2 : intervalHours) * 60;

      int notificationId = 1000;
      final now = DateTime.now();

      const androidDetails = AndroidNotificationDetails(
        'water_reminder_channel',
        'Nhắc nhở uống nước',
        channelDescription: 'Thông báo nhắc nhở uống nước định kỳ',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      for (int currentMinutes = startTotalMinutes;
      currentMinutes <= endTotalMinutes;
      currentMinutes += intervalMinutes) {
        final slotHour = currentMinutes ~/ 60;
        final slotMinute = currentMinutes % 60;

        try {
          var scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            slotHour,
            slotMinute,
          );

          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

          await _notificationsPlugin.zonedSchedule(
            id: notificationId++,
            title: 'water_reminder_notification_title'.tr(),
            body: 'water_reminder_notification_body'.tr(),
            scheduledDate: tzScheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (e) {
          debugPrint('Lỗi đặt lịch cho slot $slotHour:$slotMinute -> $e');
        }
      }
    } catch (e) {
      debugPrint('Lỗi schedulePeriodicReminders: $e');
    }
  }
}