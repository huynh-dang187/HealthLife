import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Hỏi xác nhận tạo thiết bị mới khi mã chưa tồn tại.
///
/// Trả về `true` nếu người dùng đồng ý tạo, `false`/`null` nếu huỷ.
Future<bool?> showSosConfirmCreateDialog(BuildContext context, String code) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: UIColors.white,
      title: AppText.semiBold(
        tr(LocaleKeys.sos_pair_not_found_title),
        fontSize: 16,
      ),
      content: AppText.medium(
        tr(
          LocaleKeys.sos_pair_not_found_message,
          namedArgs: {'code': code},
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: AppText.medium(tr(LocaleKeys.sos_manage_cancel)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: AppText.semiBold(
            tr(LocaleKeys.sos_pair_create_new),
            color: UIColors.coral,
          ),
        ),
      ],
    ),
  );
}
