import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';

class HeightRuler extends StatefulWidget {
  const HeightRuler({
    super.key,
    required this.valueCm,
    required this.onChanged,
    this.stepPx = 6,
    this.indicatorColor = UIColors.pink,
    required this.unit, // New
    required this.minCm, // New (đổi theo unit ở screen)
    required this.maxCm,
  });

  final int valueCm;
  final ValueChanged<int> onChanged;
  final int minCm;
  final int maxCm;
  final double stepPx;
  final Color indicatorColor;
  final HeightUnit unit;

  @override
  State<HeightRuler> createState() => _HeightRulerState();
}

class _HeightRulerState extends State<HeightRuler> {
  static const double _rulerHeight = 64;
  static const double _labelAreaHeight = 18;

  final ScrollController _controller = ScrollController();
  double _viewportWidth = 0;
  bool _inited = false;
  int _lastEmitted = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_inited && _viewportWidth > 0) {
        _inited = true;
        _lastEmitted = widget.valueCm;
        _jumpTo(widget.valueCm);
      }
    });
  }

  @override
  void didUpdateWidget(covariant HeightRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_inited && widget.valueCm != oldWidget.valueCm) {
      final current = _valueFromOffset(_controller.offset);
      if (current != widget.valueCm) _scrollTo(widget.valueCm);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final value = _valueFromOffset(
      _controller.offset,
    ).clamp(widget.minCm, widget.maxCm);
    if (value != _lastEmitted) {
      _lastEmitted = value;
      widget.onChanged(value);
    }
  }

  int _valueFromOffset(double offset) =>
      widget.minCm + (offset / widget.stepPx).round();

  double _targetOffset(int value) => (value - widget.minCm) * widget.stepPx;

  void _jumpTo(int value) {
    if (!_controller.hasClients) return;
    _controller.jumpTo(
      _targetOffset(
        value,
      ).clamp(0.0, _controller.position.maxScrollExtent).toDouble(),
    );
  }

  void _scrollTo(int value) {
    if (!_controller.hasClients) return;
    _controller.animateTo(
      _targetOffset(
        value,
      ).clamp(0.0, _controller.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportWidth = constraints.maxWidth;
        final contentWidth =
            (widget.maxCm - widget.minCm) * widget.stepPx + _viewportWidth;
        final centerX = _viewportWidth / 2;

        return Column(
          children: [
            SizedBox(
              height: _rulerHeight + _labelAreaHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: CustomPaint(
                        size: Size(
                          contentWidth,
                          _rulerHeight + _labelAreaHeight,
                        ),
                        painter: _RulerPainter(
                          minCm: widget.minCm,
                          maxCm: widget.maxCm,
                          stepPx: widget.stepPx,
                          rulerHeight: _rulerHeight,
                          centerX: centerX,
                          unit: widget.unit,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: centerX - 1,
                    top: 0,
                    bottom: _labelAreaHeight,
                    child: IgnorePointer(
                      child: Container(width: 2, color: widget.indicatorColor),
                    ),
                  ),
                  Positioned(
                    bottom: _labelAreaHeight - 8,
                    left: centerX - 7,
                    child: IgnorePointer(
                      child: CustomPaint(
                        size: const Size(14, 9),
                        painter: _TrianglePainter(widget.indicatorColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _CenterNumbers(
              value: widget.valueCm,
              color: widget.indicatorColor,
              unit: widget.unit,
            ),
          ],
        );
      },
    );
  }
}

class _CenterNumbers extends StatelessWidget {
  const _CenterNumbers({
    required this.value,
    required this.color,
    required this.unit,
  });

  final int value;
  final Color color;
  final HeightUnit unit;

  @override
  Widget build(BuildContext context) {
    if (unit == HeightUnit.ft) {
      return Center(
        child: Text(
          (value / 30.48).toStringAsFixed(2),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i != 0) const SizedBox(width: 18),
          i == 2
              ? Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                )
              : Text(
                  '${value + i - 2}',
                  style: const TextStyle(
                    color: Color(0xFFB9B9B9),
                    fontSize: 13,
                  ),
                ),
        ],
      ],
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.minCm,
    required this.maxCm,
    required this.stepPx,
    required this.rulerHeight,
    required this.centerX,
    required this.unit,
  });

  final int minCm;
  final int maxCm;
  final double stepPx;
  final double rulerHeight;
  final double centerX;
  final HeightUnit unit;

  static const _minorColor = Color(0xFFD6D6D6);
  static const _majorColor = Color(0xFF9A9A9A);
  static const _labelColor = Color(0xFF9A9A9A);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1.5;
    final baseY = rulerHeight;

    for (var v = minCm; v <= maxCm; v++) {
      final x = centerX + (v - minCm) * stepPx;
      final isFootMark = unit == HeightUnit.ft && _isFootMark(v);
      double tickHeight;
      Color color;
      if (isFootMark || (unit == HeightUnit.cm && v % 10 == 0)) {
        tickHeight = 22;
        color = _majorColor;
      } else if (v % 5 == 0) {
        tickHeight = 14;
        color = _minorColor;
      } else {
        tickHeight = 8;
        color = _minorColor;
      }
      paint.color = color;
      canvas.drawLine(Offset(x, baseY), Offset(x, baseY - tickHeight), paint);

      if (isFootMark) {
        _drawLabel(canvas, x, baseY, '${(v / 30.48).round()}');
      } else if (unit == HeightUnit.cm && v % 10 == 0) {
        _drawLabel(canvas, x, baseY, '$v');
      }
    }
  }

  bool _isFootMark(int v) {
    final k = (v / 30.48).round();
    return (k * 30.48).round() == v;
  }

  void _drawLabel(Canvas canvas, double x, double baseY, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: _labelColor, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, baseY + 5));
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.minCm != minCm ||
      oldDelegate.maxCm != maxCm ||
      oldDelegate.stepPx != stepPx ||
      oldDelegate.centerX != centerX ||
      oldDelegate.unit != unit;
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
