import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthlife/src/core/presentation/page/app.dart';
import 'package:healthlife/src/features/sos_iot/data/services/sos_notification_service.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('health_news');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignIn.instance.initialize();
  await EasyLocalization.ensureInitialized();

  // Khởi tạo hạ tầng notification SOS (FCM + local notification + full-screen).
  await SosNotificationService.instance.initialize();

await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://ttdvkuuwxynvtenququeb.supabase.co',
    ),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_a5Vhhso3Uz-wZwjYRnwGuQ_cxjo2sKi',
    ),
  );

  runApp(const MyApp());
}