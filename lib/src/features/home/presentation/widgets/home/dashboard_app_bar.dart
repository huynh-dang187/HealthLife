import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/color_extension.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../../../../common/constants/colors.dart';
import '../../../../../common/extensions/num_x.dart';
import 'animated_search_hint.dart';

// ignore: must_be_immutable
class DashboardAppBar extends StatelessWidget {
  DashboardAppBar({super.key});
  TextEditingController searchHome = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: AnimatedSearchHint(
                controller: searchHome,
                hintPadding: const EdgeInsets.only(left: 12, right: 30),
                hints: [
                  context.tr(LocaleKeys.home_search_hint_1),
                  context.tr(LocaleKeys.home_search_hint_2),
                  context.tr(LocaleKeys.home_search_hint_3),
                ],
                child: AppTF.common(
                  controller: searchHome,
                  rightWidget: Assets.svg.iconSearch.svg(
                    width: 18,
                    colorFilter: UIColors.darkBackground.filter,
                  ),
                  borderCicular: 23,
                ),
              ),
            ),
          ),
          12.gap,
          _RoundAction(
            icon: Assets.svg.icDrawer.svg(width: 18),
            onTap: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.onTap,
    this.hasDot = false,
  });

  final Widget icon;
  final VoidCallback onTap;
  final bool hasDot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: UIColors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: UIColors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            if (hasDot)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: UIColors.coral,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
