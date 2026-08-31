import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/greeting_banner.dart';
import '../widgets/health_experience.dart';
import '../widgets/news_section.dart';
import '../widgets/quick_features.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      // Thanh search ghim cố định
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
            child: const DashboardAppBar(),
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
    );
  }
}
