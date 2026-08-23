import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/dropdown.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  static const _localeByDisplay = {
    'Tiếng việt': Locale('vi'),
    'English': Locale('en'),
  };

  late String _selectedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = context.locale.languageCode == 'en'
        ? _localeByDisplay.keys.last
        : _localeByDisplay.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    return AppDropdown(
      items: _localeByDisplay.keys.toList(),
      selected: _selectedLanguage,
      onChanged: (value) {
        if (value == _selectedLanguage) return;
        setState(() => _selectedLanguage = value);
        context.setLocale(_localeByDisplay[value]!);
      },
      btn: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.regular(_selectedLanguage, fontSize: 13,maxLines: 1,),
            6.gap,
            Assets.svg.icDropdown.svg(width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}
