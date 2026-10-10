import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Vùng các nút thao tác: Tắt còi / Đã xử lý / Gọi khẩn cấp.
class SosAlertActionButtons extends StatelessWidget {
  const SosAlertActionButtons({
    super.key,
    required this.onStop,
    required this.onAcknowledge,
    required this.onCall,
  });

  final VoidCallback onStop;
  final VoidCallback onAcknowledge;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nút chính: nền trắng chữ đỏ, to nhất
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: onStop,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade900,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AppText.bold(
              context.tr(LocaleKeys.sos_stop_alarm),
              fontSize: 17,
              color: Colors.red.shade900,
            ),
          ),
        ),
        12.gap,
        // Xác nhận đã xử lý: đóng màn hình + đánh dấu trên hệ thống.
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onAcknowledge,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            child: AppText.bold(
              context.tr(LocaleKeys.sos_alert_acknowledge),
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        14.gap,
        _SecondaryButton(
          icon: Icons.phone,
          label: context.tr(LocaleKeys.sos_call_family),
          onTap: onCall,
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: AppText.semiBold(label, fontSize: 13, color: Colors.white),
      ),
    );
  }
}
