import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

late Location tzLocation;

void setupTZLocation() {
  tzLocation = getLocation('Asia/Ho_Chi_Minh'); // đổi đúng múi giờ VN
  setLocalLocation(tzLocation);
}

TZDateTime tzNow() =>
    TZDateTime.now(tzLocation); // chỉ giữ 1 hàm, bỏ getter trùng

TZDateTime tzSecond(int second) => tzMillisecond(second * 1000);

TZDateTime tzMillisecond(int millisecond) =>
    TZDateTime.fromMillisecondsSinceEpoch(tzLocation, millisecond);

TZDateTime tzToday([int hour = 0, int minute = 0, int second = 0]) {
  final now = tzNow();
  return TZDateTime(
    tzLocation,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
    second,
  );
}

final Map<String, Map<String, DateFormat>> _fmts = {};

String tzFormat(TZDateTime tzdt, String format, {String locale = 'vi_VN'}) {
  final locFmts = _fmts.putIfAbsent(locale, () => {});
  final fmt = locFmts.putIfAbsent(format, () => DateFormat(format, locale));
  return fmt.format(tzdt);
}
