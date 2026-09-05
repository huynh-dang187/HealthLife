import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class AppGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isFigma;
  final Color? color;
  final BoxBorder? border;

  // Tham số tinh chỉnh hiệu ứng (mặc định = cũ)
  final double refraction;
  final double depth;
  final double dispersion;
  final double frost;
  final Color? glassColor;

  const AppGlass({
    super.key,
    required this.child,
    required this.borderRadius,
    this.isFigma = true,
    this.color,
    this.border,
    this.refraction = 80,
    this.depth = 20,
    this.dispersion = 50,
    this.frost = 4,
    this.glassColor,
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
                refraction: refraction,
                depth: depth,
                dispersion: dispersion,
                frost: frost,
                lightAngle: -pi / 4,
                glassColor:
                    glassColor ?? const Color.fromARGB(0, 255, 255, 255),
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
