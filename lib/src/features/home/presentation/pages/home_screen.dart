import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/colors.dart';
import '../../../../features/daily_tips/data/repositories/daily_tip_repository.dart';
import '../../../../features/daily_tips/presentation/cubit/daily_tip_cubit.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/greeting_banner.dart';
import '../widgets/health_experience.dart';
import '../widgets/news_section.dart';
import '../widgets/quick_features.dart';

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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QuickFeatures(),
                      HealthExperience(),
                      NewsSection(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
