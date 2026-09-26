import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Card hiển thị thông tin thiết bị gây báo động khẩn cấp.
class SosAlertInfoCard extends StatelessWidget {
  const SosAlertInfoCard({
    super.key,
    required this.deviceName,
    required this.batteryLevel,
    required this.time,
  });

  final String deviceName;
  final int batteryLevel;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.sensors,
            label: context.tr(LocaleKeys.sos_device),
            value: deviceName,
          ),
          12.gap,
          _InfoRow(
            icon: Icons.battery_full,
            label: context.tr(LocaleKeys.sos_battery_level),
            value: '$batteryLevel%',
          ),
          12.gap,
          _InfoRow(
            icon: Icons.access_time,
            label: context.tr(LocaleKeys.sos_time),
            value: time,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        10.gap,
        AppText.regular(label, fontSize: 13, color: Colors.white70),
        const Spacer(),
        Flexible(
          child: AppText.semiBold(
            value,
            fontSize: 14,
            color: Colors.white,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}