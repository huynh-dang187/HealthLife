import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';
import 'items/quick_feature_item.dart';

class QuickFeatures extends StatelessWidget {
  const QuickFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: AppText.semiBold('Các chức năng chính', fontSize: 16),
        ),
        12.gap,
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _features.length,
            separatorBuilder: (_, __) => 8.gap,
            itemBuilder: (context, index) {
              final f = _features[index];
              return QuickFeatureItem(
                icon: f.icon,
                title: f.title,
                color: f.color,
                onTap: () => context.push(f.router),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureData {
  const _FeatureData(
    this.icon,
    this.title,
    this.color,
    this.router,
  );
  final IconData icon;
  final String title;
  final Color color;
  final String router;
}

const _features = [
  _FeatureData(
    Icons.sos,
    'Thiết bị SOS',
    UIColors.coral,
    RouteNames.sos_device,
  ),
  _FeatureData(
    Icons.medication,
    'Tra cứu thuốc',
    UIColors.pink,
    RouteNames.drug_lookup,
  ),
  _FeatureData(
    Icons.local_hospital,
    'Tìm bệnh viện',
    UIColors.pink,
    RouteNames.hospital_finder,
  ),
  _FeatureData(
    Icons.water_drop,
    'Nhắc uống nước',
    UIColors.vibrantBlue,
    RouteNames.water_reminder,
  ),
];
