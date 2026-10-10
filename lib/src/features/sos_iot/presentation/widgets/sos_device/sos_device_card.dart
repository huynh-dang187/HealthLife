import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../data/models/sos_device.dart';

/// Card một thiết bị SOS trong danh sách ở hub.
class SosDeviceCard extends StatelessWidget {
  const SosDeviceCard({super.key, required this.device, required this.onTap});

  final SosDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastText = device.lastTriggeredAt == null
        ? tr(LocaleKeys.sos_hub_never_triggered)
        : DateFormat('HH:mm dd/MM/yyyy').format(device.lastTriggeredAt!);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
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
                color: UIColors.coral.withAlpha(24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: UIColors.coral,
              ),
            ),
            12.gap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bold(device.deviceName, fontSize: 15),
                  6.gap,
                  Row(
                    children: [
                      const Icon(
                        Icons.battery_std,
                        size: 14,
                        color: UIColors.textBody,
                      ),
                      4.gap,
                      AppText.medium(
                        '${device.batteryLevel}%',
                        fontSize: 12,
                        color: UIColors.textBody,
                      ),
                    ],
                  ),
                  4.gap,
                  AppText.medium(
                    '${tr(LocaleKeys.sos_hub_last_trigger)}: $lastText',
                    fontSize: 12,
                    color: UIColors.textBody,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: UIColors.textBody),
          ],
        ),
      ),
    );
  }
}
