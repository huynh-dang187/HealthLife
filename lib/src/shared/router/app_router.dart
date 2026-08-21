import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: _guard,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const _TempHomePage(),
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

class _TempHomePage extends StatelessWidget {
  const _TempHomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('HLife App - Đang xây dựng')),
    );
  }
}
