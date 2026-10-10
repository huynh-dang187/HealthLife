import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../data/models/sos_alert_record.dart';
import '../../../data/repositories/sos_device_repository.dart';
import 'sos_alert_status_chip.dart';

/// Lịch sử cảnh báo (50 bản mới nhất) của một thiết bị, cập nhật realtime.
class SosAlertsHistory extends StatelessWidget {
  const SosAlertsHistory({
    super.key,
    required this.repo,
    required this.deviceId,
  });

  final SosDeviceRepository repo;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SosAlertRecord>>(
      stream: repo.watchAlerts(deviceId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppText.medium(
            tr(LocaleKeys.sos_pair_failed),
            color: UIColors.textBody,
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final alerts = snapshot.data!;
        if (alerts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: AppText.medium(
                tr(LocaleKeys.sos_manage_no_alerts),
                color: UIColors.textBody,
              ),
            ),
          );
        }
        return Column(
          children: alerts.map((a) => _AlertItem(alert: a)).toList(),
        );
      },
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.alert});

  final SosAlertRecord alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: UIColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UIColors.separate),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: UIColors.coral,
            size: 20,
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold(
                  tr(LocaleKeys.sos_manage_alert_triggered),
                  fontSize: 14,
                ),
                2.gap,
                AppText.medium(
                  DateFormat('HH:mm dd/MM/yyyy').format(alert.triggeredAt),
                  fontSize: 12,
                  color: UIColors.textBody,
                ),
                6.gap,
                SosAlertStatusChip(acknowledged: alert.isAcknowledged),
              ],
            ),
          ),
          AppText.medium(
            '${alert.batteryLevel}%',
            fontSize: 12,
            color: UIColors.textBody,
          ),
        ],
      ),
    );
  }
}
