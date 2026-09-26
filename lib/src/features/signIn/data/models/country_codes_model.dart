import 'package:healthlife/generated/locale_keys.g.dart';

class CountryCode {
  final String nameKey;
  final String dialCode;
  final String flagEmoji;

  const CountryCode(this.nameKey, this.dialCode, this.flagEmoji);
}

const kVietnamCountry = CountryCode(
  LocaleKeys.country_vietnam,
  '+84',
  '🇻🇳',
);

List<CountryCode> kCountryCodes = const [
  CountryCode(LocaleKeys.country_vietnam, '+84', '🇻🇳'),
  CountryCode(LocaleKeys.country_united_states, '+1', '🇺🇸'),
  CountryCode(LocaleKeys.country_united_kingdom, '+44', '🇬🇧'),
  CountryCode(LocaleKeys.country_south_korea, '+82', '🇰🇷'),
  CountryCode(LocaleKeys.country_japan, '+81', '🇯🇵'),
  CountryCode(LocaleKeys.country_china, '+86', '🇨🇳'),
  CountryCode(LocaleKeys.country_taiwan, '+886', '🇹🇼'),
  CountryCode(LocaleKeys.country_hong_kong, '+852', '🇭🇰'),
  CountryCode(LocaleKeys.country_india, '+91', '🇮🇳'),
  CountryCode(LocaleKeys.country_singapore, '+65', '🇸🇬'),
  CountryCode(LocaleKeys.country_thailand, '+66', '🇹🇭'),
  CountryCode(LocaleKeys.country_malaysia, '+60', '🇲🇾'),
  CountryCode(LocaleKeys.country_indonesia, '+62', '🇮🇩'),
  CountryCode(LocaleKeys.country_philippines, '+63', '🇵🇭'),
  CountryCode(LocaleKeys.country_australia, '+61', '🇦🇺'),
  CountryCode(LocaleKeys.country_canada, '+1', '🇨🇦'),
  CountryCode(LocaleKeys.country_france, '+33', '🇫🇷'),
  CountryCode(LocaleKeys.country_germany, '+49', '🇩🇪'),
  CountryCode(LocaleKeys.country_italy, '+39', '🇮🇹'),
  CountryCode(LocaleKeys.country_spain, '+34', '🇪🇸'),
];