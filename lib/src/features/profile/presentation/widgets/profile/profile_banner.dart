import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/profile/profile_screen_cubit.dart';

class ProfileBanner extends StatefulWidget {
  const ProfileBanner({super.key, this.height = 240});

  final double height;

  @override
  State<ProfileBanner> createState() => _ProfileBannerState();
}

class _ProfileBannerState extends State<ProfileBanner>
    with SingleTickerProviderStateMixin {
  late final List<ProfileBubble> _bubbles;
  late final double _period;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _bubbles = context.read<ProfileScreenCubit>().bubbles;
    _period = _bubbles.fold(0.0, (m, b) => math.max(m, b.delay + b.duration));
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [UIColors.pinkLight, UIColors.pink],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final w = MediaQuery.sizeOf(context).width;
          final h = widget.height;
          return Stack(
            children: [
              for (final b in _bubbles)
                _BubbleTile(bubble: b, t: t, period: _period, w: w, h: h),
            ],
          );
        },
      ),
    );
  }
}

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({
    required this.bubble,
    required this.t,
    required this.period,
    required this.w,
    required this.h,
  });

  final ProfileBubble bubble;
  final double t;
  final double period;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final local = ((t * period) - bubble.delay) / bubble.duration;
    final p = local.clamp(0.0, 1.0);
    if (local < 0 || p >= 1) return const SizedBox.shrink();

    final size = bubble.size;
    final y = h + size - p * (h + size * 2);
    final x =
        (bubble.x * w - size / 2) +
        math.sin(p * math.pi * 1.5) * 12;
    final opacity = bubble.alpha * math.sin(p * math.pi);

    return Positioned(
      left: x,
      top: y,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: opacity * 0.4),
              blurRadius: size / 3,
            ),
          ],
        ),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}