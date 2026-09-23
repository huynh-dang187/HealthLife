import 'package:gap/gap.dart';

extension NumberExtension on num {
  Gap get gap => Gap(toDouble());

  /// '10000' -> '10.000' (dấu chấm hàng nghìn kiểu Việt Nam).
  String get vnFormat {
    final s = toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return buffer.toString();
  }
}