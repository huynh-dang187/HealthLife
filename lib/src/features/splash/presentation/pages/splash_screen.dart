import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/router/route_names.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Bắt đầu lắng nghe auth NGAY (Firebase đang khôi phục trạng thái đăng nhập)
    final authFuture = FirebaseAuth.instance.authStateChanges().first;

    // Chờ animation splash
    await Future.delayed(const Duration(seconds: 3));
    final user = await authFuture;
    if (!mounted) return;

    // Chưa đăng nhập → vào màn giới thiệu
    if (user == null) {
      context.go(RouteNames.introduction);
      return;
    }

    // Đã đăng nhập → kiểm tra hồ sơ đã hoàn thiện chưa
    final completed = await _isProfileCompleted(user.uid);
    if (!mounted) return;
    context.go(completed ? RouteNames.home : RouteNames.profile_name);
  }

  Future<bool> _isProfileCompleted(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['profileCompleted'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: context.paddingBottomForButton),
        child: Column(
          children: [
            Expanded(
              child: Lottie.asset(
                Assets.lottie.intro.intro,
                width: 250,
                height: 120,
              ),
            ),
            Center(child: AppText.bold("Lựa chọn số 1 cho sức khỏe của bạn")),
          ],
        ),
      ),
    );
  }
}
