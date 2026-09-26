import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Vùng 3 nút thao tác: Tắt còi / Gọi khẩn cấp / Xem vị trí.
class SosAlertActionButtons extends StatelessWidget {
  const SosAlertActionButtons({
    super.key,
    required this.onStop,
    required this.onCall,
    required this.onMap,
  });

  final VoidCallback onStop;
  final VoidCallback onCall;
  final VoidCallback onMap;

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
        14.gap,
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: Icons.phone,
                label: context.tr(LocaleKeys.sos_call_family),
                onTap: onCall,
              ),
            ),
            14.gap,
            Expanded(
              child: _SecondaryButton(
                icon: Icons.map,
                label: context.tr(LocaleKeys.sos_view_location),
                onTap: onMap,
              ),
            ),
          ],
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