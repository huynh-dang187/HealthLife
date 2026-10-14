import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_cubit.dart';
import 'package:healthlife/src/features/water_reminder/presentation/cubit/water_cubit.dart';

import 'drawer_avatar.dart';
import 'drawer_stat_chip.dart';

/// Header của drawer: avatar + tên/email và 2 chip tóm tắt bước chân, nước.
class HomeDrawerHeader extends StatelessWidget {
  const HomeDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state.user;
    final steps = context.watch<ActivityDashboardCubit>().state.todaySteps;
    final water = context.watch<WaterCubit>().state;
    final number = NumberFormat.decimalPattern('en_US');
    final liters = NumberFormat('0.0', 'en_US');

    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : context.tr(LocaleKeys.home_greeting_fallback_name);
    final subtitle = user?.email ?? user?.phoneNumber ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE877A0), Color(0xFFF6A9C4)],
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DrawerAvatar(user: user),
              14.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bold(
                      name,
                      fontSize: 17,
                      color: UIColors.white,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      4.gap,
                      AppText.regular(
                        subtitle,
                        fontSize: 12.5,
                        color: UIColors.white.withValues(alpha: 0.85),
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          18.gap,
          Row(
            children: [
              Expanded(
                child: DrawerStatChip(
                  icon: Icons.directions_walk_rounded,
                  label: context.tr(
                    LocaleKeys.home_drawer_steps,
                    namedArgs: {'count': number.format(steps)},
                  ),
                ),
              ),
              10.gap,
              Expanded(
                child: DrawerStatChip(
                  icon: Icons.water_drop_rounded,
                  label: context.tr(
                    LocaleKeys.home_drawer_water,
                    namedArgs: {
                      'current': liters.format(water.currentIntake / 1000.0),
                      'goal': liters.format(water.dailyGoal / 1000.0),
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
