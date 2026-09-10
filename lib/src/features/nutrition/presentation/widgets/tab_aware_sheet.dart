import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';

/// Chiều cao vùng thanh tab bar nổi (kính) của MainTabScreen
/// (`extendBody: true` + `bottomNavigationBar` cao 80).
///
/// Dùng làm bottom margin để bottom sheet dừng phía trên tab bar,
/// không che khuất nó khi mở từ một tab branch.
double floatingTabBarArea(BuildContext context) {
  final view = MediaQuery.viewPaddingOf(context);
  return 80.0 + view.bottom + 8.0;
}

/// Thẻ sheet nền trắng bo tròn góc trên, có bottom margin để nổi bên trên
/// tab bar. Đi kèm `backgroundColor: Colors.transparent` khi gọi
/// `showModalBottomSheet`.
Widget buildTabSafeSheet({required BuildContext context, required Widget child}) {
  return Container(
    margin: EdgeInsets.only(bottom: floatingTabBarArea(context)),
    decoration: const BoxDecoration(
      color: UIColors.lightCard,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: child,
  );
}