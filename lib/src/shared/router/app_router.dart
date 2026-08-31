import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_date_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_gender_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_height_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_name_screen.dart';
import 'package:healthlife/src/features/complete_profile/presentation/pages/profile_weight_screen.dart';
import 'package:healthlife/src/features/drug_lookup/presentation/pages/drug_lookup_screen.dart';
import 'package:healthlife/src/features/home/presentation/pages/home_screen.dart';
import 'package:healthlife/src/features/hospital_finder/presentation/pages/hospital_finder_screen.dart';
import 'package:healthlife/src/features/introduction/presentation/page/introduction_screen.dart';
import 'package:healthlife/src/features/signIn/presentation/page/signIn_screen.dart';
import 'package:healthlife/src/features/sos_iot/presentation/pages/sos_device_screen.dart';
import 'package:healthlife/src/features/splash/presentation/pages/splash_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/activity_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/chatbot_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/main_tab_screen.dart';
import 'package:healthlife/src/features/tab_bar/presentation/page/nutrition_screen.dart';
import 'package:healthlife/src/features/water_reminder/presentation/pages/water_reminder_screen.dart';

import 'route_names.dart';

class AppRouter {
  AppRouter._();

  // Các route KHÔNG cần kiểm tra đăng nhập (public)
  static const _publicRoutes = [
    RouteNames.splash,
    RouteNames.introduction,
    RouteNames.signIn,
  ];

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _guard,
    routes: [
      //Router flow newbie
      _route(RouteNames.splash, (_) => const SplashScreen()),
      _route(RouteNames.introduction, (_) => const IntroductionScreen()),
      _route(RouteNames.signIn, (_) => const SigninScreen()),
      _route(RouteNames.profile_name, (_) => ProfileName()),
      _route(RouteNames.profile_gender, (_) => ProfileGender()),
      _route(RouteNames.profile_date, (_) => ProfileDate()),
      _route(RouteNames.profile_height, (_) => const ProfileHeight()),
      _route(RouteNames.profile_weight, (_) => const ProfileWeightScreen()),
      //Router HomeScreen QuickActions
      _route(RouteNames.sos_device, (_) => const SosDeviceScreen()),
      _route(RouteNames.drug_lookup, (_) => const DrugLookScreen()),
      _route(RouteNames.hospital_finder, (_) => const HospitalScreen()),
      _route(RouteNames.water_reminder, (_) => const WaterReminderScreen()),
      //Router bottom bar đã cố định sẽ sửa lại trong tương lai
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
              _route(RouteNames.activity, (_) => const ProfileGender()),
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

    // TH1: Đang ở Splash — để Splash tự xử lý logic điều hướng riêng,
    // guard không can thiệp vào route này
    if (currentPath == RouteNames.splash) {
      return null;
    }

    // TH2: Chưa đăng nhập mà cố vào route cần đăng nhập → đá về SignIn
    if (user == null) {
      if (_publicRoutes.contains(currentPath)) {
        return null; // đang ở đúng route public, cho đi tiếp
      }
      return RouteNames
          .signIn; // cố vào route riêng tư mà chưa đăng nhập → chặn lại
    }

    // TH3: Đã đăng nhập nhưng đang cố quay lại SignIn/Introduction → đẩy đi tiếp
    if (_publicRoutes.contains(currentPath)) {
      final completed = await _isProfileCompleted(user.uid);
      return completed ? RouteNames.home : RouteNames.profile_name;
    }

    // TH4: Đã đăng nhập, đang ở trong luồng điền hồ sơ → cho phép (không redirect)
    if (currentPath.startsWith('/profile_')) {
      return null;
    }

    // TH5: Đã đăng nhập, cố vào route khác (Home, Nutrition...) nhưng CHƯA hoàn thiện hồ sơ
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
