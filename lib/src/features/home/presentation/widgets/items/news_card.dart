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
      width: 210,
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.6)],
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 28,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(title, fontSize: 12, maxLines: 2),
                6.gap,
                Row(
                  children: [
                    AppText.regular(source, fontSize: 10, color: UIColors.pink),
                    const Spacer(),
                    AppText.regular(
                      time,
                      fontSize: 10,
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
