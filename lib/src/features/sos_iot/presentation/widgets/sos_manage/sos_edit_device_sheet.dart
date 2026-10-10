import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../../data/models/sos_device.dart';

/// Bottom sheet sửa tên thiết bị + SĐT khẩn cấp.
///
/// Tự quản [TextEditingController] và dispose đúng vòng đời để tránh
/// lỗi deactivate InheritedElement khi sheet đang đóng.
/// Trả về `(deviceName, emergencyPhone)` khi lưu, `null` khi huỷ.
Future<(String, String?)?> showSosEditDeviceSheet(
  BuildContext context,
  SosDevice device,
) {
  return showModalBottomSheet<(String, String?)>(
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
      child: _SosEditDeviceSheet(device: device),
    ),
  );
}

class _SosEditDeviceSheet extends StatefulWidget {
  const _SosEditDeviceSheet({required this.device});

  final SosDevice device;

  @override
  State<_SosEditDeviceSheet> createState() => _SosEditDeviceSheetState();
}

class _SosEditDeviceSheetState extends State<_SosEditDeviceSheet> {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SingleChildScrollView(
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
                const Icon(
                  Icons.edit_rounded,
                  color: UIColors.pink,
                  size: 24,
                ),
                12.gap,
                Expanded(
                  child: AppText.bold(
                    tr(LocaleKeys.sos_manage_edit_device),
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            20.gap,
            AppText.medium(
              tr(LocaleKeys.sos_manage_device_name),
              fontSize: 13,
              color: UIColors.textBody,
            ),
            8.gap,
            AppTF.common(
              controller: _nameController,
              hintText: LocaleKeys.sos_manage_device_name,
              leftWidget: const Icon(
                Icons.devices_rounded,
                size: 20,
                color: UIColors.textBody,
              ),
              height: 48,
              borderCicular: 14,
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
              leftWidget: const Icon(
                Icons.phone_rounded,
                size: 20,
                color: UIColors.textBody,
              ),
              height: 48,
              borderCicular: 14,
            ),
            20.gap,
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _nameController,
              builder: (context, value, _) => AppButton.fill(
                onTap: _save,
                title: tr(LocaleKeys.sos_manage_save),
                enable: value.text.trim().isNotEmpty,
                height: 48,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
