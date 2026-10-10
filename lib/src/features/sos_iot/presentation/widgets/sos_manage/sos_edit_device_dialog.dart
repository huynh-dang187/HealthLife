import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../../data/models/sos_device.dart';

/// Dialog sửa tên thiết bị + SĐT khẩn cấp.
///
/// Tự quản [TextEditingController] và dispose đúng vòng đời để tránh
/// lỗi deactivate InheritedElement khi dialog đang đóng.
/// Trả về `(deviceName, emergencyPhone)` khi lưu, `null` khi huỷ.
class SosEditDeviceDialog extends StatefulWidget {
  const SosEditDeviceDialog({super.key, required this.device});

  final SosDevice device;

  @override
  State<SosEditDeviceDialog> createState() => _SosEditDeviceDialogState();
}

class _SosEditDeviceDialogState extends State<SosEditDeviceDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.device.deviceName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.device.emergencyPhone ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    Navigator.pop(context, (name, phone.isEmpty ? null : phone));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UIColors.white,
      scrollable: true,
      title: AppText.semiBold(
        tr(LocaleKeys.sos_manage_edit_device),
        fontSize: 16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            tr(LocaleKeys.sos_manage_device_name),
            fontSize: 13,
            color: UIColors.textBody,
          ),
          8.gap,
          AppTF.common(
            controller: _nameController,
            hintText: LocaleKeys.sos_manage_device_name,
          ),
          16.gap,
          AppText.medium(
            tr(LocaleKeys.sos_manage_emergency_phone),
            fontSize: 13,
            color: UIColors.textBody,
          ),
          8.gap,
          AppTF.common(
            controller: _phoneController,
            hintText: LocaleKeys.sos_manage_emergency_phone_hint,
            keyboardType: TextInputType.phone,
          ),
        ],
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
          valueListenable: _nameController,
          builder: (context, value, _) => AppButton.fill(
            onTap: _save,
            title: tr(LocaleKeys.sos_manage_save),
            enable: value.text.trim().isNotEmpty,
          ),
        ),
      ],
    );
  }
}
