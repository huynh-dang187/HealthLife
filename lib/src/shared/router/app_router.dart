import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/features/splash/presentation/pages/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _guard,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const TempHomePage(),
      ),
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
}
