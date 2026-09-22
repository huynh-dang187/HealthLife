import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:healthlife/firebase_options.dart';
import 'package:healthlife/src/features/sos_iot/data/models/sos_alert_args.dart';
import 'package:healthlife/src/shared/router/app_router.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

/// ID kênh thông báo SOS.
/// LƯU Ý: Android KHÔNG cho đổi âm thanh/importance/audioAttributes của
/// channel đã tồn tại. Nếu thay đổi cấu hình channel, phải tăng ID này để
/// channel được tạo lại với cấu hình mới.
const String sosChannelId = 'sos_emergency_v5';

/// Hàm chạy ở isolate nền khi app bị kill/background.
/// Nhận FCM data-only và bung màn hình full-screen bằng local notification.
@pragma('vm:entry-point')
Future<void> sosFirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  if (data.isEmpty || data['type'] != 'sos_alert') return;

  debugPrint('SOS_HEADLESS: nhận FCM data, tiến hành bung full-screen...');

  final args = SosAlertArgs.fromFcmData(data);
  if (args == null) return;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await createSosNotificationChannel(plugin);
  await showSosNotification(plugin, args);
}

/// Hiển thị notification SOS full-screen. Dùng chung cả foreground lẫn nền.
Future<void> showSosNotification(
  FlutterLocalNotificationsPlugin plugin,
  SosAlertArgs args,
) async {
  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      sosChannelId,
      'Báo động SOS Khẩn cấp',
      channelDescription: 'Kênh phát còi hú khẩn cấp',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('sos_sound'),
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      autoCancel: false,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  );
  await plugin.show(
    id: 0,
    title: '🚨 BÁO ĐỘNG KHẨN CẤP SOS',
    body: '${args.deviceName} vừa được kích hoạt! Chạm để xem ngay.',
    notificationDetails: notificationDetails,
    payload: jsonEncode(args.toJson()),
  );
}

/// Tạo channel SOS (bắt buộc khởi tạo plugin trước khi gọi).
Future<void> createSosNotificationChannel(
  FlutterLocalNotificationsPlugin plugin,
) async {
  const channel = AndroidNotificationChannel(
    sosChannelId,
    'Báo động SOS Khẩn cấp',
    description: 'Kênh phát còi hú khẩn cấp',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('sos_sound'),
    enableVibration: true,
    bypassDnd: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );

  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// Cầu nối duy nhất giữa FCM + local notification + điều hướng màn hình SOS.
class SosNotificationService {
  SosNotificationService._();

  static final SosNotificationService instance = SosNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Args đang chờ điều hướng (app vừa khởi động bằng notification).
  SosAlertArgs? _pendingArgs;

  /// Router đã được dựng xong (true sau frame đầu tiên của runApp).
  bool _routerReady = false;

  /// Có báo động SOS đang chờ chưa tiêu thụ (guard redirect dùng để check).
  bool get hasPendingAlert => _pendingArgs != null;

  /// Tiêu thụ args chờ (gọi một lần duy nhất khi vào trang SOS).
  SosAlertArgs? takePendingAlert() {
    final args = _pendingArgs;
    _pendingArgs = null;
    return args;
  }

  /// Khởi tạo toàn bộ hạ tầng notification SOS.
  Future<void> initialize() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await createSosNotificationChannel(_localNotifications);

    final android =
        _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(sosFirebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) => _handleMessage(message));
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    // Lưu FCM token vào Firestore mỗi khi có người dùng đăng nhập.
    // (authStateChanges phát ngay giá trị hiện tại nếu đã đăng nhập sẵn.)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) _saveFcmToken(user.uid);
    });

    // App bị kill và mở lại bằng thông báo SOS.
    final initial = await fcm.getInitialMessage();
    if (initial != null) _handleMessage(initial);

    // Đánh dấu router đã sẵn sàng sau frame đầu tiên của runApp.
    // Trước đó (cold start từ notification) guard redirect sẽ tự chuyển
    // hướng sang /sos_alert, KHÔNG push trực tiếp để tránh stack lộn xộn.
    WidgetsBinding.instance.addPostFrameCallback((_) => _routerReady = true);
  }

  void _handleMessage(RemoteMessage message) {
    final args = SosAlertArgs.fromFcmData(message.data);
    if (args == null) return;
    debugPrint(
      'SOS_FOREGROUND: nhận FCM khi app mở, bung cảnh báo + điều hướng...',
    );
    // App đang mở: Android bỏ qua fullScreenIntent, tắt thành heads-up
    // kèm tiếng còi (channel) để người dùng luôn thấy/nghe ngay.
    showSosNotification(_localNotifications, args);
    _scheduleNavigation(args);
  }

  void _onTokenRefresh(String token) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _writeToken(uid, token);
  }

  Future<void> _saveFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (token == null) return;
      await _writeToken(uid, token);
    } catch (_) {
      // Offline/thiếu quyền: token sẽ được lưu lại ở lần đăng nhập hoặc refresh sau.
    }
  }

  Future<void> _writeToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Lỗi ghi (offline...): bỏ qua để không chặn luồng đăng nhập.
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    final args = SosAlertArgs.fromJson(
      jsonDecode(payload) as Map<String, dynamic>,
    );
    if (args == null) return;
    _scheduleNavigation(args);
  }

  void _scheduleNavigation(SosAlertArgs args) {
    _pendingArgs = args;
    // Router chưa sẵn sàng (cold start từ notification): chỉ set pending,
    // guard redirect trong app_router sẽ tự đưa vào /sos_alert. Push lúc này
    // sẽ tạo stack [/splash, /sos_alert], rồi splash gọi go(home) thay cả
    // stack → không muốn.
    if (_routerReady) _navigateToSos(args);
  }

  void _navigateToSos(SosAlertArgs args) {
    AppRouter.router.push(RouteNames.sos_alert, extra: args);
  }
}