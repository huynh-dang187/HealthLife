import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class ContinueButton extends StatelessWidget {
  final Widget icon;
  final Color textColor;
  final bool isFilled;
  final VoidCallback? onTap;

  const ContinueButton({
    super.key,
    required this.icon,
    required this.textColor,
    this.isFilled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        AppText.semiBold(
          context.tr(LocaleKeys.sign_in_continue_with),
          fontSize: 16,
          color: textColor,
        ),
        8.gap,
        icon,
      ],
    );
    return isFilled
        ? AppButton.fill(onTap: onTap ?? () {}, titleWidget: title)
        : AppButton.outline(onTap: onTap ?? () {}, titleWidget: title);
  }
}
