import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthlife/src/core/presentation/page/app.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

// 1. Hàm nhận tin nhắn nền
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('health_news');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GoogleSignIn.instance.initialize();
  await EasyLocalization.ensureInitialized();

  try {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await fcm.getToken().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('FCM_ERROR: Lấy token bị timeout');
        return null;
      },
    );

    debugPrint('========================================');
    debugPrint('MY_FCM_TOKEN: $token');
    debugPrint('========================================');
  } catch (e) {
    debugPrint('FCM_ERROR_CATCH: $e');
  }

  // 2. KHỞI TẠO PLUGIN TRƯỚC KHI TẠO CHANNEL (Bắt buộc)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  const AndroidNotificationChannel sosChannel = AndroidNotificationChannel(
    'sos_emergency_v3',
    'Báo động SOS Khẩn cấp',
    description: 'Kênh phát còi hú khẩn cấp',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('sos_sound'),
    enableVibration: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(sosChannel);

  // 4. Cho phép thông báo hiển thị cả khi app đang mở trực tiếp
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await Supabase.initialize(
    url: 'https://ttdvkuuwxynvtenquueb.supabase.co',
    publishableKey: 'sb_publishable_a5Vhhso3Uz-wZwjYRnwGuQ_cxjo2sKi',
  );

  runApp(const MyApp());
}
