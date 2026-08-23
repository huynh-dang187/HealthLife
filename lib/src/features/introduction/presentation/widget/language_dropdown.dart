import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          isDense: true,
          items: _localeByDisplay.keys
              .map(
                (lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(
                    lang,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null || value == _selectedLanguage) return;
            setState(() => _selectedLanguage = value);
            context.setLocale(_localeByDisplay[value]!);
          },
        ),
      ),
    );
  }
}
