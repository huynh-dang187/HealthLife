import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../cubit/daily_tip_cubit.dart';
import '../cubit/daily_tip_state.dart';

class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyTipCubit, DailyTipState>(
      builder: (context, state) {
        final emoji = state.displayEmoji;
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
                      state.displayTip,
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
                child: emoji != null
                    ? Text(emoji, style: const TextStyle(fontSize: 20))
                    : Icon(
                        Icons.medical_services_outlined,
                        size: 20,
                        color: UIColors.pink,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
