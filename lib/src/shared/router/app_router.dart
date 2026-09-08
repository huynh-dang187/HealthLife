import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_date_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_gender_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_height_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_name_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_weight_screen.dart';
import 'package:healthlife/src/features/drug_lookup/presentation/pages/drug_lookup_screen.dart';
import 'package:healthlife/src/features/health_news/data/models/news_article_model.dart';
import 'package:healthlife/src/features/health_news/presentation/pages/health_news_screen.dart';
import 'package:healthlife/src/features/health_news/presentation/pages/news_detail_screen.dart';
import 'package:healthlife/src/features/health_news/presentation/pages/news_webview_screen.dart';
import 'package:healthlife/src/features/home/presentation/pages/home_screen.dart';
import 'package:healthlife/src/features/hospital_finder/presentation/pages/hospital_finder_screen.dart';
import 'package:healthlife/src/features/introduction/presentation/page/introduction_screen.dart';
import 'package:healthlife/src/features/medicine_search/presentation/cubit/medicine_search_cubit.dart';
import 'package:healthlife/src/features/medicine_search/presentation/page/medicine_search_page.dart';
import 'package:healthlife/src/features/profile/presentation/pages/profile_screen.dart';
import 'package:healthlife/src/features/signIn/data/models/otp_args_model.dart';
import 'package:healthlife/src/features/signIn/presentation/page/phone_input_screen.dart';
import 'package:healthlife/src/features/signIn/presentation/page/signIn_screen.dart';
import 'package:healthlife/src/features/sos_iot/presentation/pages/sos_device_screen.dart';
import 'package:healthlife/src/features/splash/presentation/pages/splash_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/activity_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/chatbot_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/main_tab_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/nutrition_screen.dart';
import 'package:healthlife/src/features/water_reminder/presentation/pages/water_reminder_screen.dart';

import '../../features/signIn/presentation/page/otp_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  // Danh sách các route công khai không bắt buộc phải đăng nhập
  static const _publicRoutes = [
    RouteNames.splash,
    RouteNames.introduction,
    RouteNames.signIn,
    RouteNames.phone_input,
    RouteNames.phone_otp,
    RouteNames.home,
    RouteNames.medicine_search,
  ];

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _guard,
    routes: [
      // Router flow newbie
      _route(RouteNames.splash, (_) => const SplashScreen()),
      _route(RouteNames.introduction, (_) => const IntroductionScreen()),
      _route(RouteNames.signIn, (_) => const SigninScreen()),
      _route(RouteNames.phone_input, (_) => const PhoneInputScreen()),
      GoRoute(
        path: RouteNames.phone_otp,
        builder: (context, state) => OtpScreen(otpArgs: state.extra as OtpArgs),
      ),
      _route(RouteNames.profile_name, (_) => ProfileName()),
      _route(RouteNames.profile_gender, (_) => ProfileGender()),
      _route(RouteNames.profile_date, (_) => ProfileDate()),
      _route(RouteNames.profile_height, (_) => const ProfileHeight()),
      _route(RouteNames.profile_weight, (_) => const ProfileWeightScreen()),

      // Route tra cứu thuốc bọc BlocProvider
      _route(
        RouteNames.medicine_search,
        (_) => BlocProvider(
          create: (context) => MedicineSearchCubit(),
          child: const MedicineSearchPage(),
        ),
      ),

      // Router homeScreen features
      _route(RouteNames.health_news, (_) => const HealthNewsScreen()),
      GoRoute(
        path: RouteNames.news_webview,
        builder: (context, state) =>
            NewsWebViewScreen(link: state.extra as String),
      ),
      GoRoute(
        path: RouteNames.news_detail,
        builder: (context, state) =>
            NewsDetailScreen(article: state.extra as NewsArticleModel),
      ),

      // Router HomeScreen QuickActions
      _route(RouteNames.sos_device, (_) => const SosDeviceScreen()),
      _route(RouteNames.drug_lookup, (_) => const DrugLookScreen()),
      _route(RouteNames.hospital_finder, (_) => const HospitalScreen()),
      _route(RouteNames.water_reminder, (_) => const WaterReminderScreen()),

      // Router bottom bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainTabScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [_route(RouteNames.home, (_) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              _route(RouteNames.activity, (_) => const ActivityScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _route(RouteNames.nutrition, (_) => const NutritionScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _route(RouteNames.profile, (_) => const ProfileScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [_route(RouteNames.chatbot, (_) => const ChatbotScreen())],
          ),
        ],
      ),
    ],
  );

  static Future<String?> _guard(
    BuildContext context,
    GoRouterState state,
  ) async {
    final currentPath = state.matchedLocation;
    final user = FirebaseAuth.instance.currentUser;

    // TH1: Đang ở Splash, Home hoặc Tra cứu thuốc khi ép test — bỏ qua điều hướng
    if (currentPath == RouteNames.splash ||
        currentPath == RouteNames.home ||
        currentPath == RouteNames.medicine_search) {
      return null;
    }

    // TH2: Chưa đăng nhập mà cố vào route cần đăng nhập → đá về SignIn
    if (user == null) {
      if (_publicRoutes.contains(currentPath)) {
        return null;
      }
      return RouteNames.signIn;
    }

    // TH3: Đã đăng nhập nhưng đang cố quay lại SignIn/Introduction → đẩy đi tiếp
    if (_publicRoutes.contains(currentPath)) {
      final completed = await _isProfileCompleted(user.uid);
      return completed ? RouteNames.home : RouteNames.profile_name;
    }

    // TH4: Đã đăng nhập, đang ở trong luồng điền hồ sơ → cho phép
    if (currentPath.startsWith('/profile_')) {
      return null;
    }

    // TH5: Đã đăng nhập, cố vào route khác nhưng CHƯA hoàn thiện hồ sơ
    final completed = await _isProfileCompleted(user.uid);
    if (!completed) {
      return RouteNames.profile_name;
    }

    // Mọi điều kiện đều ổn, cho đi tiếp
    return null;
  }

  static Future<bool> _isProfileCompleted(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['profileCompleted'] ?? false;
  }

  static GoRoute _route(String path, WidgetBuilder page) => GoRoute(
    path: path,
    builder: (context, state) => _LocaleAwareBuilder(builder: page),
  );
}

class _LocaleAwareBuilder extends StatelessWidget {
  const _LocaleAwareBuilder({required this.builder});
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    context.locale;
    return builder(context);
  }
}
