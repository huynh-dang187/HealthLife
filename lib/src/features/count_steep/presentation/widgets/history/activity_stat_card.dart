import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../data/models/activity_stat_item.dart';

/// Một card thống kê: nền tối, label nhỏ ở trên, giá trị lớn đậm, dòng phụ.
class ActivityStatCard extends StatelessWidget {
  const ActivityStatCard({super.key, required this.item});

  final ActivityStatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.darkCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            item.label,
            fontSize: 11,
            color: UIColors.white.withValues(alpha: 0.6),
            maxLines: 1,
          ),
          8.gap,
          AppText.bold(item.value, fontSize: 20, color: UIColors.white),
          4.gap,
          AppText.regular(
            item.subtitle,
            fontSize: 11,
            color: UIColors.white.withValues(alpha: 0.6),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Grid 2x2 gồm các [ActivityStatCard].
class ActivityStatsGrid extends StatelessWidget {
  const ActivityStatsGrid({super.key, required this.items});

  final List<ActivityStatItem> items;

  @override
  Widget build(BuildContext context) {
    final chunked = <List<ActivityStatItem>>[];
    for (var i = 0; i < items.length; i += 2) {
      chunked.add(items.sublist(i, (i + 2).clamp(0, items.length)));
    }

    return Column(
      children: [
        for (var i = 0; i < chunked.length; i++) ...[
          if (i > 0) 12.gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < chunked[i].length; j++) ...[
                if (j > 0) 12.gap,
                Expanded(child: ActivityStatCard(item: chunked[i][j])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}