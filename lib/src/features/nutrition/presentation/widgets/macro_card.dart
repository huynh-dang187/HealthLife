import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Card tròn nhỏ hiển thị một chỉ số dinh dưỡng: icon tròn màu pastel
/// + giá trị dạng phân số (VD "22/199g").
class MacroCard extends StatelessWidget {
  const MacroCard({
    super.key,
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.value,
    this.percent,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final String value;

  /// 0 → 100: vẽ thanh ngang mảnh bên dưới.
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final p = (percent ?? 0).clamp(0.0, 100.0) / 100;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UIColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 17, color: color),
          ),
          10.gap,
          AppText.medium(label, fontSize: 11, color: UIColors.textBody),
          2.gap,
          AppText.semiBold(value, fontSize: 11.5, color: UIColors.text),
          10.gap,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 4,
              backgroundColor: Color.lerp(bg, UIColors.white, 0.5),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}