import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

/// Bottom sheet nhập SĐT để thêm người nhận.
///
/// Trả về SĐT đã trim khi xác nhận, `null` khi huỷ.
Future<String?> showSosAddRecipientSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: UIColors.lightCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: const _SosAddRecipientSheet(),
    ),
  );
}

class _SosAddRecipientSheet extends StatefulWidget {
  const _SosAddRecipientSheet();

  @override
  State<_SosAddRecipientSheet> createState() => _SosAddRecipientSheetState();
}

class _SosAddRecipientSheetState extends State<_SosAddRecipientSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: UIColors.separate,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          20.gap,
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: UIColors.pinkLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: UIColors.pink,
                  size: 24,
                ),
              ),
              12.gap,
              Expanded(
                child: AppText.bold(
                  tr(LocaleKeys.sos_manage_add_recipient),
                  fontSize: 17,
                ),
              ),
            ],
          ),
          6.gap,
          AppText.regular(
            tr(LocaleKeys.sos_manage_add_recipient_desc),
            fontSize: 13,
            color: UIColors.textBody,
          ),
          20.gap,
          AppTF.common(
            controller: _controller,
            hintText: LocaleKeys.sos_manage_phone_hint,
            keyboardType: TextInputType.phone,
            leftWidget: const Icon(
              Icons.phone_rounded,
              size: 20,
              color: UIColors.textBody,
            ),
            height: 48,
            borderCicular: 14,
            autofocus: true,
            onSubmitted: (_) => _confirm(),
          ),
          20.gap,
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => AppButton.fill(
              onTap: _confirm,
              title: tr(LocaleKeys.sos_manage_confirm),
              enable: value.text.trim().isNotEmpty,
              height: 48,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
