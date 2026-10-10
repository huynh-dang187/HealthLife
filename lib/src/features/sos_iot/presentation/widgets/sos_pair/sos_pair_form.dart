import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../../data/repositories/sos_device_repository.dart';

/// Form nhập mã thiết bị để ghép nối (hoặc hiển thị lỗi + nút thử lại).
class SosPairForm extends StatelessWidget {
  const SosPairForm({
    super.key,
    required this.controller,
    required this.errorKey,
    required this.onSubmit,
    required this.onReset,
  });

  final TextEditingController controller;

  /// Key thông báo lỗi đã localize, `null` nếu chưa có lỗi.
  final String? errorKey;

  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.medium(
          tr(LocaleKeys.sos_pair_subtitle),
          color: UIColors.textBody,
        ),
        24.gap,
        AppText.semiBold(tr(LocaleKeys.sos_pair_code_label)),
        8.gap,
        AppTF.common(
          controller: controller,
          hintText: LocaleKeys.sos_pair_code_hint,
          onSubmitted: (_) => onSubmit(),
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
            LengthLimitingTextInputFormatter(
              SosDeviceRepository.maxDeviceCodeLength,
            ),
          ],
          textColor: errorKey != null ? UIColors.error : null,
        ),
        if (errorKey != null) ...[
          10.gap,
          AppText.medium(
            tr(errorKey!),
            color: UIColors.error,
            fontSize: 13,
          ),
        ],
        24.gap,
        AppButton.fill(
          onTap: onSubmit,
          title: tr(LocaleKeys.sos_pair_button),
        ),
        if (errorKey != null) ...[
          12.gap,
          AppButton.outline(
            onTap: onReset,
            title: tr(LocaleKeys.sos_pair_try_again),
          ),
        ],
      ],
    );
  }
}
