import 'package:easy_localization/easy_localization.dart';
import 'package:healthlife/generated/locale_keys.g.dart';

String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return LocaleKeys.health_news_time_just_now.tr();
  if (diff.inHours < 1) {
    return LocaleKeys.health_news_time_minutes_ago.tr(
      namedArgs: {'minutes': '${diff.inMinutes}'},
    );
  }
  if (diff.inDays < 1) {
    return LocaleKeys.health_news_time_hours_ago.tr(
      namedArgs: {'hours': '${diff.inHours}'},
    );
  }
  return DateFormat('dd/MM/yyyy').format(dateTime);
}
