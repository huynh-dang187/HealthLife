import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_cubit.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_state.dart';
import 'package:healthlife/src/features/health_news/data/repositories/rss_repository.dart';
import 'package:healthlife/src/features/health_news/presentation/cubit/health_news_cubit.dart';
import 'package:healthlife/src/features/summary_card/presentation/widgets/health_summary_row.dart';
import 'package:healthlife/src/features/water_reminder/presentation/cubit/water_cubit.dart';
import 'package:healthlife/src/features/water_reminder/presentation/cubit/water_state.dart';
import 'package:healthlife/src/shared/router/route_names.dart';
import 'package:hive_ce/hive.dart';

import '../../../../common/constants/colors.dart';
import '../../../../features/daily_tips/data/repositories/daily_tip_repository.dart';
import '../../../../features/daily_tips/presentation/cubit/daily_tip_cubit.dart';
import '../widgets/home/dashboard_app_bar.dart';
import '../widgets/home/greeting_banner.dart';
import '../widgets/home/health_experience.dart';
import '../widgets/home/news_section.dart';
import '../widgets/home/quick_features.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return BlocProvider(
      create: (_) => DailyTipCubit(DailyTipRepository())..loadTip(),
      child: BlocProvider(
        create: (_) =>
            HealthNewsCubit(RssRepository(Hive.box('health_news')))..loadNews(),
        child: BlocProvider(
          create: (_) => WaterCubit()..loadInitialData(),
          child: BlocProvider(
            create: (context) => ActivityDashboardCubit(
              ActivityRepository(),
              userCubit: context.read<UserCubit>(),
            )..start(),
            child: Scaffold(
              backgroundColor: UIColors.lightBackground,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(statusBarHeight + 54),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFBD5E3), Color(0xFFE877A0)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: DashboardAppBar(),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE877A0), Color(0xFFFBD5E3)],
                        ),
                      ),
                      child: const SafeArea(
                        bottom: false,
                        top: false,
                        child: GreetingBanner(),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: UIColors.lightBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const QuickFeatures(),
                            BlocBuilder<WaterCubit, WaterState>(
                              builder: (context, water) {
                                return BlocBuilder<
                                  ActivityDashboardCubit,
                                  ActivityDashboardState
                                >(
                                  builder: (context, activity) {
                                    return HealthSummaryRow(
                                      currentLiters:
                                          water.currentIntake / 1000.0,
                                      goalLiters: water.dailyGoal / 1000.0,
                                      cupCount: water.todayLogs.length,
                                      currentSteps: activity.todaySteps,
                                      goalSteps: activity.stepGoal,
                                      streakDays: activity.streak,
                                      onWaterTap: () => context.push(
                                        RouteNames.water_reminder,
                                      ),
                                      onWaterAddTap: () => context.push(
                                        RouteNames.water_reminder,
                                      ),
                                      onStepTap: () => context.push(
                                        RouteNames.activity_dashboard,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const HealthExperience(),
                            const NewsSection(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
