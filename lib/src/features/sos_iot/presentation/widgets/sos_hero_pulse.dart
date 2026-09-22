import 'package:flutter/material.dart';

/// Hiệu ứng sóng xung kích tỏa ra liên tục quanh icon cảnh báo khẩn cấp.
class SosHeroPulse extends StatelessWidget {
  const SosHeroPulse({
    super.key,
    required this.scale,
    required this.opacity,
    this.color = Colors.white,
    this.size = 200,
    this.iconSize = 96,
  });

  /// Animation điều khiển mức phóng to của sóng.
  final Animation<double> scale;

  /// Animation điều khiển độ mờ của sóng (mờ dần khi nở ra).
  final Animation<double> opacity;

  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: scale,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: (size - 30) * scale.value,
              height: (size - 30) * scale.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: opacity.value),
                  width: 3,
                ),
              ),
            ),
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: color.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
            ),
            Icon(
              Icons.warning_amber_rounded,
              size: iconSize,
              color: color.withValues(alpha: 0.95),
            ),
          ],
        ),
      ),
    );
  }
}