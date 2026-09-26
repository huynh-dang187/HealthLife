import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
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
          child: AppText.semiBold(
            context.tr(LocaleKeys.home_quick_features_title),
            fontSize: 16,
          ),
        ),
        12.gap,
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _features.length,
            separatorBuilder: (_, _) => 12.gap,
            itemBuilder: (context, index) {
              final f = _features[index];
              return QuickFeatureItem(
                icon: f.icon,
                title: context.tr(f.title),
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
  final Widget icon;
  final String title;
  final Color color;
  final String router;
}

final _features = [
  _FeatureData(
    Assets.png.icSosDevice.image(width: 40, height: 40),
    LocaleKeys.home_quick_sos_device,
    UIColors.coral,
    RouteNames.sos_device,
  ),
  _FeatureData(
    Assets.png.icDrugLookup.image(),
    LocaleKeys.home_quick_medicine_search,
    UIColors.green,
    RouteNames.medicine_search,
  ),
  _FeatureData(
    Assets.png.icHospitalFinder.image(),
    LocaleKeys.home_quick_hospital_finder,
    Colors.teal,
    RouteNames.hospitalFinder,
  ),
  _FeatureData(
    Assets.png.icWaterReminder.image(),
    LocaleKeys.home_quick_water_reminder,
    Colors.blueAccent,
    RouteNames.water_reminder,
  ),
  _FeatureData(
    Assets.png.icFootCounter.image(),
    LocaleKeys.home_quick_activity_dashboard,
    Colors.yellow,
    RouteNames.activity_dashboard,
  ),
];
