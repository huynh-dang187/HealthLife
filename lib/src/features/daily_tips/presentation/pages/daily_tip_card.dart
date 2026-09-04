import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../cubit/daily_tip_cubit.dart';

class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tip = context.watch<DailyTipCubit>().state.tip;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDFE), Color(0xFFFFE1EC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold(
                  'Mỗi ngày một lời khuyên',
                  fontSize: 14,
                  color: UIColors.pink,
                ),
                6.gap,
                AppText.medium(
                  tip?.tip ?? 'Chăm sóc sức khỏe mỗi ngày bạn nhé',
                  fontSize: 13,
                  color: UIColors.text,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          12.gap,
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: UIColors.pinkLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.water_drop_outlined,
              size: 28,
              color: UIColors.pink,
            ),
          ),
        ],
      ),
    );
  }
}
