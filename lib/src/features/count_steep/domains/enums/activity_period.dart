import 'package:healthlife/generated/locale_keys.g.dart';

enum ActivityPeriod {
  week(LocaleKeys.count_steep_period_week),
  month(LocaleKeys.count_steep_period_month),
  year(LocaleKeys.count_steep_period_year);

  const ActivityPeriod(this.labelKey);

  final String labelKey;
}