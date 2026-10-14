import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class DrawerFeature {
  const DrawerFeature({
    required this.icon,
    required this.color,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String route;
}

const drawerFeatures = [
  DrawerFeature(
    icon: Icons.sos_rounded,
    color: UIColors.coral,
    label: LocaleKeys.home_quick_sos_device,
    route: RouteNames.sos_device,
  ),
  DrawerFeature(
    icon: Icons.medication_rounded,
    color: UIColors.green,
    label: LocaleKeys.home_quick_medicine_search,
    route: RouteNames.medicine_search,
  ),
  DrawerFeature(
    icon: Icons.local_hospital_rounded,
    color: Colors.teal,
    label: LocaleKeys.home_quick_hospital_finder,
    route: RouteNames.hospitalFinder,
  ),
  DrawerFeature(
    icon: Icons.water_drop_rounded,
    color: Colors.blueAccent,
    label: LocaleKeys.home_quick_water_reminder,
    route: RouteNames.water_reminder,
  ),
  DrawerFeature(
    icon: Icons.directions_walk_rounded,
    color: Colors.orange,
    label: LocaleKeys.home_quick_activity_dashboard,
    route: RouteNames.activity_dashboard,
  ),
  DrawerFeature(
    icon: Icons.restaurant_rounded,
    color: Colors.deepOrange,
    label: LocaleKeys.nutrition_title,
    route: RouteNames.nutrition,
  ),
  DrawerFeature(
    icon: Icons.smart_toy_rounded,
    color: Colors.deepPurple,
    label: LocaleKeys.home_drawer_chatbot,
    route: RouteNames.chatbot,
  ),
  DrawerFeature(
    icon: Icons.newspaper_rounded,
    color: Colors.blueGrey,
    label: LocaleKeys.health_news_title,
    route: RouteNames.health_news,
  ),
];
