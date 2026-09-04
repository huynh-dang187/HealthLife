import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          AppText.regular(
            'Xin chào',
            fontSize: 14,
            color: UIColors.black.withValues(alpha: 0.7),
          ),
          4.gap,
          AppText.bold(
            _greetingName(context),
            fontSize: 20,
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'chào mừng bạn đến với ',
                  style: TextStyle(
                    fontSize: 13,
                    color: UIColors.black.withValues(alpha: 0.75),
                  ),
                ),
                TextSpan(
                  text: 'HLIFE',
                  style: TextStyle(
                    fontSize: 13,
                    color: UIColors.coral, // ← HLIFE màu hồng
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(text: '!'),
              ],
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
  return (name?.isNotEmpty ?? false) ? name! : 'Bạn yêu quý';
}
