import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/features/introduction/presentation/page/introduction_screen.dart';
import 'package:healthlife/src/features/signIn/presentation/page/signIn_screen.dart';
import 'package:healthlife/src/features/splash/presentation/pages/splash_screen.dart';

import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _guard,
    routes: [
      _route(RouteNames.splash, (_) => const SplashScreen()),
      _route(RouteNames.introduction, (_) => const IntroductionScreen()),
      _route(RouteNames.signIn, (_) => const SigninScreen()),
      // Các route khác thêm dần khi code từng module
    ],
  );

  static Future<String?> _guard(
    BuildContext context,
    GoRouterState state,
  ) async {
    // Sau này thay bằng kiểm tra FirebaseAuth.instance.currentUser
    // if (state.fullPath == RouteNames.home && chuaDangNhap) {
    //   return RouteNames.login;
    // }
    return null;
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
