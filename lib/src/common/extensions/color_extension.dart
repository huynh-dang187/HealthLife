import 'package:flutter/material.dart';

extension UIColorFilterX on Color {
  ColorFilter get filter => ColorFilter.mode(this, BlendMode.srcIn);
}
