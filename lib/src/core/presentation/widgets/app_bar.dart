import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/assets.gen.dart';
import '../../../common/constants/colors.dart';
import '../../../common/extensions/color_extension.dart';
import '../../../common/extensions/context_x.dart';
import '../../../common/extensions/num_x.dart';
import '../../../shared/router/route_names.dart';
import 'button.dart';
import 'text.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.rightBtns,
    this.leftBtn,
    this.onBack,
    this.bgColor,
    this.iconColor,
    this.titleColor,
    this.centerTitle = false,
  });

  final String title;
  final Widget? titleWidget;
  final Widget? leftBtn;
  final List<Widget>? rightBtns;
  final VoidCallback? onBack;
  final Color? bgColor;
  final Color? iconColor;
  final Color? titleColor;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? UIColors.text;
    final effectiveTitleColor = titleColor ?? UIColors.text;

    return Container(
      height: context.appBarHeight,
      padding: EdgeInsets.only(top: context.topPadding),
      decoration: BoxDecoration(color: bgColor ?? const Color(0xFFFFF9FA)),
      child: Row(
        children: [
          leftBtn ??
              AppButton.widget(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Assets.svg.icArrowLeft.svg(
                    colorFilter: effectiveIconColor.filter,
                  ),
                ),
                onTap: () {
                  if (onBack != null) {
                    onBack!();
                  } else if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.home);
                  }
                },
              ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: centerTitle
                  ? Align(
                      alignment: Alignment.center,
                      child:
                          titleWidget ??
                          AppText.bold(
                            title.isEmpty ? ' ' : title,
                            fontSize: 18,
                            color: effectiveTitleColor,
                          ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child:
                          titleWidget ??
                          AppText.bold(
                            title.isEmpty ? ' ' : title,
                            fontSize: 18,
                            color: effectiveTitleColor,
                          ),
                    ),
            ),
          ),
          rightBtns != null
              ? SizedBox(
                  height: 24,
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(right: 24),
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: rightBtns![index],
                      );
                    },
                    separatorBuilder: (context, index) => 16.gap,
                    itemCount: rightBtns!.length,
                  ),
                )
              : 60.gap,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(46);
}
