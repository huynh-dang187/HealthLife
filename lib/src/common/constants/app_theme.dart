import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: UIColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: UIColors.pink,
        brightness: Brightness.light,
      ),
    );
  }
}
