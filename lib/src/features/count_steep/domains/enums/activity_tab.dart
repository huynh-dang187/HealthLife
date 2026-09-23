import 'package:healthlife/generated/locale_keys.g.dart';

enum ActivityTab {
  overview(LocaleKeys.count_steep_tab_overview),
  history(LocaleKeys.count_steep_tab_history);

  const ActivityTab(this.labelKey);

  final String labelKey;
}