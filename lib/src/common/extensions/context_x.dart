import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);

  // ===== Kích thước màn hình =====
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenWidth => MediaQuery.sizeOf(this).width;

  // ===== Bàn phím =====
  double get keyboardHeight => _mediaQuery.viewInsets.bottom;
  bool get isKeyboardOpen => keyboardHeight > 0;

  // ===== Vùng an toàn (tránh tai thỏ, thanh điều hướng) =====
  double get topPadding => _mediaQuery.padding.top;
  double get bottomPadding =>
      _mediaQuery.padding.bottom > 0 ? _mediaQuery.padding.bottom : 24;
  double get paddingBottomForButton => bottomPadding > 0 ? bottomPadding : 16;

  // ===== AppBar =====
  double get appBarHeight => topPadding + 46;

  // // ===== Điều hướng =====
  // void goBack() {
  //   if (canPop()) {
  //     pop();
  //   } else {
  //     go(RouteNames.home);
  //   }
  // }

  // ===== Theme rút gọn (đọc nhanh không cần gõ dài) =====
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Brightness get brightness => Theme.of(this).brightness;
  bool get isDarkMode => brightness == Brightness.dark;
}
