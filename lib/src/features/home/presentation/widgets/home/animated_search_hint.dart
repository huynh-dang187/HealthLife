import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class AnimatedSearchHint extends StatefulWidget {
  const AnimatedSearchHint({
    super.key,
    required this.child,
    required this.hints,
    this.controller,
    this.hintPadding = const EdgeInsets.only(left: 12, right: 30),
    this.barHeight = 46,
    this.fontSize = 14,
    this.holdDuration = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 450),
  });

  final Widget child;
  final List<String> hints;
  final TextEditingController? controller;
  final EdgeInsets hintPadding;
  final double barHeight;
  final double fontSize;
  final Duration holdDuration;
  final Duration transitionDuration;

  @override
  State<AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<AnimatedSearchHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int _index = 0;
  bool _focused = false;

  bool get _visible => !_focused && (widget.controller?.text.isEmpty ?? true);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: widget.holdDuration + widget.transitionDuration,
    )..addStatusListener(_onStatus);
    widget.controller?.addListener(_onInputChanged);
    if (_visible) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onInputChanged);
    _anim.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _visible) {
      setState(() => _index = (_index + 1) % widget.hints.length);
      _anim.forward(from: 0);
    }
  }

  void _onInputChanged() {
    if (_visible) {
      if (!_anim.isAnimating) _anim.forward(from: 0);
    } else {
      _anim.stop();
    }
    setState(() {});
  }

  void _onFocusChanged(bool focused) {
    if (focused == _focused) return;
    _focused = focused;
    _onInputChanged();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hints.length < 2) return widget.child;
    final lineHeight = widget.fontSize * 1.4;

    return Focus(
      onFocusChange: _onFocusChanged,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: widget.barHeight,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Padding(
                  padding: widget.hintPadding,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (context, _) => _SlidingHints(
                        index: _index,
                        hints: widget.hints,
                        value: _anim.value,
                        holdFraction:
                            widget.holdDuration.inMilliseconds /
                            (_anim.duration?.inMilliseconds ?? 1),
                        lineHeight: lineHeight,
                        fontSize: widget.fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidingHints extends StatelessWidget {
  const _SlidingHints({
    required this.index,
    required this.hints,
    required this.value,
    required this.holdFraction,
    required this.lineHeight,
    required this.fontSize,
  });

  final int index;
  final List<String> hints;
  final double value;
  final double holdFraction;
  final double lineHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final inTransition = value > holdFraction;
    final progress = inTransition
        ? (value - holdFraction) / (1 - holdFraction)
        : 0.0;
    final currentOffset = inTransition ? -progress : 0.0;
    final nextOffset = inTransition ? (1 - progress) : 1.0;
    final nextIndex = (index + 1) % hints.length;

    return SizedBox(
      height: lineHeight,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: _hint(hints[index], currentOffset),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: _hint(hints[nextIndex], nextOffset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text, double offset) {
    return Transform.translate(
      offset: Offset(0, offset * lineHeight),
      child: AppText.regular(
        text,
        fontSize: fontSize,
        color: UIColors.textBody,
        maxLines: 1,
      ),
    );
  }
}
