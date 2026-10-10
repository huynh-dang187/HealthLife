import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

/// Dialog nhập SĐT để thêm người nhận.
///
/// Trả về SĐT đã trim khi xác nhận, `null` khi huỷ.
class SosAddRecipientDialog extends StatefulWidget {
  const SosAddRecipientDialog({super.key});

  @override
  State<SosAddRecipientDialog> createState() => _SosAddRecipientDialogState();
}

class _SosAddRecipientDialogState extends State<SosAddRecipientDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UIColors.white,
      title: AppText.semiBold(
        tr(LocaleKeys.sos_manage_add_recipient),
        fontSize: 16,
      ),
      content: SizedBox(
        height: 46,
        child: AppTF.common(
          controller: _controller,
          hintText: LocaleKeys.sos_manage_phone_hint,
          keyboardType: TextInputType.phone,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: AppText.medium(
            tr(LocaleKeys.sos_manage_cancel),
            fontSize: 14,
            color: UIColors.textBody,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => AppButton.fill(
            onTap: () => Navigator.pop(context, value.text.trim()),
            title: tr(LocaleKeys.sos_manage_confirm),
            enable: value.text.trim().isNotEmpty,
          ),
        ),
      ],
    );
  }
}
