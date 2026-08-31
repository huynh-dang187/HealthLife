import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.title,
    required this.source,
    required this.time,
    this.imageColor,
    this.icon = Icons.newspaper,
  });

  final String title;
  final String source;
  final String time;
  final Color? imageColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = imageColor ?? UIColors.pinkLight;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: UIColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 26,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(title, fontSize: 13, maxLines: 2),
                6.gap,
                Row(
                  children: [
                    AppText.regular(source, fontSize: 11, color: UIColors.pink),
                    const Spacer(),
                    AppText.regular(
                      time,
                      fontSize: 11,
                      color: UIColors.textBody,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
