import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: UIColors.lightBackground,
      cardColor: UIColors.lightCard,
      dividerColor: UIColors.lightBorder,
      colorScheme: ColorScheme.fromSeed(
        seedColor: UIColors.pink,
        brightness: Brightness.light,
        surface: UIColors.lightSurface,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: UIColors.lightTextPrimary),
        bodyMedium: TextStyle(color: UIColors.lightTextSecondary),
        titleLarge: TextStyle(
          color: UIColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: UIColors.darkBackground,
      cardColor: UIColors.darkCard,
      dividerColor: UIColors.darkBorder,
      colorScheme: ColorScheme.fromSeed(
        seedColor: UIColors.pink,
        brightness: Brightness.dark,
        surface: UIColors.darkSurface,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: UIColors.darkTextPrimary),
        bodyMedium: TextStyle(color: UIColors.darkTextSecondary),
        titleLarge: TextStyle(
          color: UIColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
