import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';

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
            child: AppTF.common(
              controller: searchHome,
              rightWidget: Assets.svg.iconSearch.svg(
                width: 18,
                color: UIColors.darkBackground,
              ),
              borderCicular: 23,
              hintText: "Nhập nội dung tìm kiếm của bạn",
            ),
          ),
          10.gap,
          _RoundAction(
            icon: Assets.svg.icNotification.svg(width: 18),
            onTap: () {},
          ),
          8.gap,
          _RoundAction(
            icon: Assets.svg.icDrawer.svg(width: 18),
            onTap: () {},
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
