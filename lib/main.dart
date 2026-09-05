import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:healthlife/src/core/presentation/page/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  // Khởi tạo kết nối Supabase
  await Supabase.initialize(
    url: 'https://ttdvkuuwxynvtenquueb.supabase.co',
    anonKey: 'sb_publishable_a5Vhhso3Uz-wZwjYRnwGuQ_cxjo2sKi',
  );

  runApp(const MyApp());
}