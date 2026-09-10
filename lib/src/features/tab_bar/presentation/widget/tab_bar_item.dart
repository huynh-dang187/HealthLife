import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class TabBarItem extends StatelessWidget {
  const TabBarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? UIColors.pink : UIColors.black;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: selected
                      ? [
                          UIColors.pink.withAlpha(200),
                          UIColors.pink.withAlpha(0),
                        ]
                      : [Colors.transparent, Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
              alignment: Alignment.center,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
                child: icon,
              ),
            ),
            2.gap,
            AppText.bold(
              title,
              fontSize: 10,
              color: color,
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
