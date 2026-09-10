class CountryCode {
  final String name;
  final String dialCode;
  final String flagEmoji;

  const CountryCode(this.name, this.dialCode, this.flagEmoji);
}

const kVietnamCountry = CountryCode('Việt Nam', '+84', '🇻🇳');

List<CountryCode> kCountryCodes = const [
  CountryCode('Việt Nam', '+84', '🇻🇳'),
  CountryCode('Hoa Kỳ', '+1', '🇺🇸'),
  CountryCode('Anh', '+44', '🇬🇧'),
  CountryCode('Hàn Quốc', '+82', '🇰🇷'),
  CountryCode('Nhật Bản', '+81', '🇯🇵'),
  CountryCode('Trung Quốc', '+86', '🇨🇳'),
  CountryCode('Đài Loan', '+886', '🇹🇼'),
  CountryCode('Hồng Kông', '+852', '🇭🇰'),
  CountryCode('Ấn Độ', '+91', '🇮🇳'),
  CountryCode('Singapore', '+65', '🇸🇬'),
  CountryCode('Thái Lan', '+66', '🇹🇭'),
  CountryCode('Malaysia', '+60', '🇲🇾'),
  CountryCode('Indonesia', '+62', '🇮🇩'),
  CountryCode('Philippines', '+63', '🇵🇭'),
  CountryCode('Úc', '+61', '🇦🇺'),
  CountryCode('Canada', '+1', '🇨🇦'),
  CountryCode('Pháp', '+33', '🇫🇷'),
  CountryCode('Đức', '+49', '🇩🇪'),
  CountryCode('Ý', '+39', '🇮🇹'),
  CountryCode('Tây Ban Nha', '+34', '🇪🇸'),
];
