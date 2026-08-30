import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class AppGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isFigma;
  final Color? color;
  final BoxBorder? border;

  const AppGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    this.isFigma = true,
    this.color,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
      child: LiquidGlassLayer(
        settings: isFigma
            ? LiquidGlassSettings.figma(
                refraction: 80,
                depth: 20,
                dispersion: 50,
                frost: 4,
                lightAngle: -pi / 4,
              )
            : LiquidGlassSettings(
                ambientStrength: 0,
                lightIntensity: 0.0,
                glassColor: color ?? const Color.fromARGB(0, 255, 255, 255),
              ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
