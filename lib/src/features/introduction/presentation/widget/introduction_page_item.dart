import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class IntroductionBottomContent extends StatelessWidget {
  final String description;
  final int currentPage;
  final int pageCount;
  final bool isLastPage;
  final VoidCallback? onStartPressed;
  final VoidCallback? onLoginPressed;

  const IntroductionBottomContent({
    super.key,
    required this.description,
    required this.currentPage,
    required this.pageCount,
    required this.isLastPage,
    this.onStartPressed,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.regular(
            description.tr(),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          48.gap,
          _DotsIndicator(currentPage: currentPage, pageCount: pageCount),
          48.gap,
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onStartPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(isLastPage ? 'Bắt đầu' : 'Tiếp theo'),
            ),
          ),
          48.gap,
          GestureDetector(
            onTap: onLoginPressed,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(text: LocaleKeys.introduction_have_account.tr()),
                  TextSpan(
                    text: LocaleKeys.login.tr(),
                    style: const TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _DotsIndicator({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? UIColors.coral : UIColors.lightTextSecondary,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
