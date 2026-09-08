import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

Future<void> showLanguageModal(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Chọn ngôn ngữ',
    barrierColor: UIColors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => const _LanguageModal(),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.94, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    ),
  );
}

class _LanguageModal extends StatefulWidget {
  const _LanguageModal();

  @override
  State<_LanguageModal> createState() => _LanguageModalState();
}

class _LanguageModalState extends State<_LanguageModal> {
  static const _vi = Locale('vi');
  static const _en = Locale('en');

  bool _isEnglish = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isEnglish = context.locale.languageCode == 'en';
  }

  void _select(bool english) {
    setState(() => _isEnglish = english);
    context.setLocale(english ? _en : _vi);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          decoration: BoxDecoration(
            color: UIColors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: UIColors.black.withValues(alpha: 0.14),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: UIColors.black.withValues(alpha: 0.12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: UIColors.black,
                    ),
                  ),
                ),
              ),
              4.gap,
              AppText.semiBold(
                'Chọn ngôn ngữ bạn muốn',
                fontSize: 17,
                color: UIColors.black,
              ),
              24.gap,
              Row(
                children: [
                  Expanded(
                    child: _LanguageOption(
                      flag: '🇻🇳',
                      label: 'Tiếng Việt',
                      selected: !_isEnglish,
                      onTap: () => _select(false),
                    ),
                  ),
                  16.gap,
                  Expanded(
                    child: _LanguageOption(
                      flag: '🇺🇸',
                      label: 'English',
                      selected: _isEnglish,
                      onTap: () => _select(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? UIColors.pink : UIColors.separate,
                width: selected ? 2.5 : 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: UIColors.pink.withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(flag, style: const TextStyle(fontSize: 30)),
          ),
          10.gap,
          AppText.medium(
            label,
            fontSize: 14,
            color: selected ? UIColors.pink : UIColors.black,
          ),
        ],
      ),
    );
  }
}
