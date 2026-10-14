import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cấu hình một bong bóng trang trí: vị trí ngang (fraction 0..1), kích thước,
/// thời gian bay (giây), độ trễ (giây) và độ mờ tối đa.
class BubbleSpec {
  const BubbleSpec({
    required this.x,
    required this.size,
    required this.duration,
    required this.delay,
    required this.alpha,
  });

  final double x;
  final double size;
  final double duration;
  final double delay;
  final double alpha;
}

class _BubbleGeometry {
  const _BubbleGeometry({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.visible,
  });

  final double x;
  final double y;
  final double size;
  final double opacity;
  final bool visible;
}

/// Nền bong bóng bay lên lặp vô hạn, dùng chung cho các banner.
///
/// Chỉ là lớp trang trí: đặt trong [Stack]/[Positioned.fill] phía sau nội dung.
class AnimatedBubbles extends StatefulWidget {
  const AnimatedBubbles({
    super.key,
    this.bubbles = defaultBubbles,
    this.color = Colors.white,
  });

  final List<BubbleSpec> bubbles;
  final Color color;

  static const List<BubbleSpec> defaultBubbles = [
    BubbleSpec(x: 0.12, size: 34, duration: 2, delay: 0, alpha: 0.22),
    BubbleSpec(x: 0.28, size: 18, duration: 3, delay: 1.2, alpha: 0.3),
    BubbleSpec(x: 0.45, size: 48, duration: 3, delay: 1.9, alpha: 0.16),
    BubbleSpec(x: 0.62, size: 22, duration: 4, delay: 2.8, alpha: 0.26),
    BubbleSpec(x: 0.78, size: 40, duration: 3.5, delay: 0.8, alpha: 0.18),
    BubbleSpec(x: 0.9, size: 26, duration: 1, delay: 3.4, alpha: 0.24),
  ];

  @override
  State<AnimatedBubbles> createState() => _AnimatedBubblesState();
}

class _AnimatedBubblesState extends State<AnimatedBubbles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _period => widget.bubbles.fold(
    0.0,
    (m, b) => math.max(m, b.delay + b.duration),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_period * 1000).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_BubbleGeometry> _bubblesAt(double t, double width, double height) {
    final period = _period;
    return [
      for (final b in widget.bubbles)
        () {
          final local = ((t * period) - b.delay) / b.duration;
          final p = local.clamp(0.0, 1.0);
          final size = b.size;
          return _BubbleGeometry(
            x: (b.x * width - size / 2) + math.sin(p * math.pi * 1.5) * 12,
            y: height + size - p * (height + size * 2),
            size: size,
            opacity: b.alpha * math.sin(p * math.pi),
            visible: local >= 0 && p < 1,
          );
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bubbles.isEmpty) return const SizedBox.shrink();
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          if (!constraints.hasBoundedHeight || w <= 0 || h <= 0) {
            return const SizedBox.shrink();
          }
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                children: [
                  for (final b in _bubblesAt(_controller.value, w, h))
                    _BubbleTile(bubble: b, color: widget.color),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.bubble, required this.color});

  final _BubbleGeometry bubble;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (!bubble.visible) return const SizedBox.shrink();
    return Positioned(
      left: bubble.x,
      top: bubble.y,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: bubble.opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: bubble.opacity * 0.4),
              blurRadius: bubble.size / 3,
            ),
          ],
        ),
        child: SizedBox(width: bubble.size, height: bubble.size),
      ),
    );
  }
}
