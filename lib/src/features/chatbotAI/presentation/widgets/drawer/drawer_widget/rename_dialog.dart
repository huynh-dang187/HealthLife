import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

Future<String?> showRenameDialog(BuildContext context, String currentTitle) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController(text: currentTitle);
      return AlertDialog(
        backgroundColor: UIColors.white,
        title: AppText.semiBold(
          LocaleKeys.chatbot_history_rename_title.tr(),
          fontSize: 16,
        ),
        content: SizedBox(
          height: 46,
          child: AppTF.common(
            controller: controller,
            hintText: currentTitle,
            height: 46,
            borderCicular: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText.medium(
              LocaleKeys.chatbot_history_cancel.tr(),
              fontSize: 14,
              color: UIColors.textBody,
            ),
          ),
          AppButton.fill(
            onTap: () => Navigator.pop(context, controller.text.trim()),
            title: LocaleKeys.chatbot_history_rename.tr(),
          ),
        ],
      );
    },
  );
}