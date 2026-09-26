import 'package:healthlife/generated/locale_keys.g.dart';

enum Gender {
  female(LocaleKeys.complete_profile_gender_female, 'female'),
  male(LocaleKeys.complete_profile_gender_male, 'male');

  const Gender(this.labelKey, this.value);

  final String labelKey;
  final String value;
}
