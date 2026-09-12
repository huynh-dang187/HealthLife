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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('health_news');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(); // giảm độ trễ khi mở Login google
  await EasyLocalization.ensureInitialized();
  // Thay thế đoạn fcm cũ bằng đoạn này:
  try {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Đặt timeout 5 giây để không làm treo app nếu máy ảo thiếu CH Play
    final token = await fcm.getToken().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint(
          'FCM_ERROR: Lấy token bị timeout (kiểm tra Google Play Services)',
        );
        return null;
      },
    );

    debugPrint('========================================');
    debugPrint('MY_FCM_TOKEN: $token');
    debugPrint('========================================');
  } catch (e) {
    debugPrint('FCM_ERROR_CATCH: $e');
  }
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel sosChannel = AndroidNotificationChannel(
    'sos_high_importance_channel', // Đúng ID này phải khớp với Cloud Function
    'Cảnh báo SOS Khẩn cấp', // Tên hiển thị trong Cài đặt thông báo
    description:
        'Kênh phát chuông báo động khi có cảnh báo khẩn cấp từ nút bấm IoT',
    importance: Importance
        .max, // Mức cao nhất: Hiện popup đè lên màn hình + Phát chuông
    playSound: true,
    enableVibration: true,
  );

  // Đăng ký channel này với hệ điều hành Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(sosChannel);
  // Khởi tạo kết nối Supabase
  await Supabase.initialize(
    url: 'https://ttdvkuuwxynvtenquueb.supabase.co',
    anonKey: 'sb_publishable_a5Vhhso3Uz-wZwjYRnwGuQ_cxjo2sKi',
  );

  runApp(const MyApp());
}
