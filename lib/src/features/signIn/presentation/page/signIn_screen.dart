import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/divider.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppButton.widget(
                  child: Assets.svg.icArrowLeft.svg(width: 24),
                  onTap: () => context.pop(),
                ),
              ],
            ),
            20.gap,
            Assets.png.icSecurity.image(width: 260, height: 190),
            50.gap,
            AppText.bold(
              "Tạo tài khoản miễn phí",
              fontSize: 24,
              color: UIColors.black,
            ),
            14.gap,
            AppText.bold(
              "Lưu trữ dữ liệu sức khỏe của bạn và nhận các thông tin phân tích được cá nhân hóa trên tất cả thiết bị của bạn",
              fontSize: 12,
              color: UIColors.black,
              maxLines: 3,
            ),
            24.gap,
            _ContinueButton(
              onTap: () {},
              isFilled: true,
              textColor: UIColors.lightBackground,
              icon: Assets.svg.icPhoneLogin.svg(width: 20),
            ),
            24.gap,
            Row(
              children: [
                const Expanded(child: AppDivider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AppText.regular("Hoặc", fontSize: 14),
                ),
                const Expanded(child: AppDivider()),
              ],
            ),
            24.gap,
            _ContinueButton(
              onTap: () {},
              textColor: UIColors.black,
              icon: Assets.svg.icEmail.svg(width: 20, color: UIColors.black),
            ),
            24.gap,
            _ContinueButton(
              onTap: () {},
              textColor: UIColors.black,
              icon: Assets.svg.icGmail.svg(width: 20, color: UIColors.coral),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final Widget icon;
  final Color textColor;
  final bool isFilled;
  final VoidCallback onTap;

  const _ContinueButton({
    required this.icon,
    required this.textColor,
    this.isFilled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        AppText.semiBold("Tiếp tục với", fontSize: 16, color: textColor),
        8.gap,
        icon,
      ],
    );
    return isFilled
        ? AppButton.fill(onTap: () {}, titleWidget: title)
        : AppButton.outline(onTap: () {}, titleWidget: title);
  }
}
