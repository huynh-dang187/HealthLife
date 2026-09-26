import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/features/daily_tips/presentation/pages/daily_tip_card.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';

class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText.regular(
                context.tr(LocaleKeys.home_greeting_hello),
                fontSize: 14,
                color: UIColors.black.withValues(alpha: 0.6),
              ),
              6.gap,
              AppText.regular(
                '👋',
              ),
            ],
          ),
          2.gap,
          AppText.italic(
            _greetingName(context),
            fontSize: 26,
            color: UIColors.black,
            fontWeight: FontWeight.bold,
          ),
          6.gap,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: UIColors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.tr(LocaleKeys.home_greeting_welcome_to),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: UIColors.black.withValues(alpha: 0.75),
                    ),
                  ),
                  TextSpan(
                    text: 'HLIFE',
                    style: TextStyle(
                      fontSize: 13,
                      color: UIColors.coral,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(text: '!'),
                ],
              ),
            ),
          ),
          20.gap,
          DailyTipCard(),
          24.gap,
        ],
      ),
    );
  }
}

String _greetingName(BuildContext context) {
  final user = context.watch<UserCubit>().state.user;
  final name = user?.displayName?.trim();
  return (name?.isNotEmpty ?? false)
      ? name!
      : context.tr(LocaleKeys.home_greeting_fallback_name);
}
