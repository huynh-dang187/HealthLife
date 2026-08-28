import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key, this.message});

  final String? message;

  // người dùng gọi chỗ này: AppLoadingScreen.show(context, message: ...)
  static Future<void> show(BuildContext context, {String? message}) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AppLoadingScreen(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: UIColors.coral),
            if (message != null) ...[
              const SizedBox(height: 16),
              AppText.medium(message ?? "Đang tải"),
            ],
          ],
        ),
      ),
    );
  }
}
