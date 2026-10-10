import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../data/models/sos_device.dart';
import '../../../data/repositories/sos_device_repository.dart';

/// Header ở màn quản lý: tên thiết bị + số người nhận + nút sửa.
class SosManageHeader extends StatelessWidget {
  const SosManageHeader({
    super.key,
    required this.device,
    required this.count,
    required this.onEdit,
  });

  final SosDevice device;
  final int count;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UIColors.separate),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: UIColors.coral.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sos, color: UIColors.coral),
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(device.deviceName, fontSize: 16),
              ],
            ),
          ),
          AppText.bold(
            '$count/${SosDeviceRepository.maxRecipients}',
            fontSize: 15,
            color: UIColors.green,
          ),
          AppButton.widget(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_outlined,
              color: UIColors.textBody,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
