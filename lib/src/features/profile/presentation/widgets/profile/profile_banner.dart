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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final period = context.read<ProfileScreenCubit>().bubblesPeriod;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (period * 1000).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileScreenCubit>();
    return Container(
      width: double.infinity,
      height: widget.height,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [UIColors.pinkLight, Color.fromARGB(54, 232, 119, 160)],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final w = MediaQuery.sizeOf(context).width;
          final h = widget.height;
          return Stack(
            children: [
              for (final b in cubit.bubblesAt(_controller.value, w, h))
                _BubbleTile(bubble: b),
            ],
          );
        },
      ),
    );
  }
}

class _BubbleTile extends StatelessWidget {
  const _BubbleTile({required this.bubble});

  final ProfileBubbleGeometry bubble;

  @override
  Widget build(BuildContext context) {
    if (!bubble.visible) return const SizedBox.shrink();
    return Positioned(
      left: bubble.x,
      top: bubble.y,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: bubble.opacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: bubble.opacity * 0.4),
              blurRadius: bubble.size / 3,
            ),
          ],
        ),
        child: SizedBox(width: bubble.size, height: bubble.size),
      ),
    );
  }
}