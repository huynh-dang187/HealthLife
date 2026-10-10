import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Nhãn trạng thái xử lý (đã xử lý / chưa xử lý) của một cảnh báo.
class SosAlertStatusChip extends StatelessWidget {
  const SosAlertStatusChip({super.key, required this.acknowledged});

  final bool acknowledged;

  @override
  Widget build(BuildContext context) {
    final color = acknowledged ? UIColors.green : UIColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText.semiBold(
        tr(
          acknowledged
              ? LocaleKeys.sos_manage_alert_acknowledged
              : LocaleKeys.sos_manage_alert_pending,
        ),
        fontSize: 11,
        color: color,
      ),
    );
  }
}
