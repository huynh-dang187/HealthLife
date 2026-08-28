import 'dart:async';

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
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.go(RouteNames.introduction);
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
