import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class FeaturePoint {
  const FeaturePoint({
    required this.icon,
    required this.background,
    required this.titleKey,
    required this.descriptionKey,
  });

  final IconData icon;
  final Color background;
  final String titleKey;
  final String descriptionKey;

  String title() => titleKey.tr();
  String description() => descriptionKey.tr();

  static List<FeaturePoint> get list => [
    FeaturePoint(
      icon: Icons.health_and_safety,
      background: const Color(0xFFFFF0F5),
      titleKey: LocaleKeys.chatbot_intro_feature_symptom_title,
      descriptionKey: LocaleKeys.chatbot_intro_feature_symptom_desc,
    ),
    FeaturePoint(
      icon: Icons.trending_up,
      background: const Color(0xFFE6F7EC),
      titleKey: LocaleKeys.chatbot_intro_feature_trend_title,
      descriptionKey: LocaleKeys.chatbot_intro_feature_trend_desc,
    ),
    FeaturePoint(
      icon: Icons.medical_information,
      background: const Color(0xFFF3EFFF),
      titleKey: LocaleKeys.chatbot_intro_feature_diag_title,
      descriptionKey: LocaleKeys.chatbot_intro_feature_diag_desc,
    ),
    FeaturePoint(
      icon: Icons.favorite,
      background: const Color(0xFFFFF4E6),
      titleKey: LocaleKeys.chatbot_intro_feature_care_title,
      descriptionKey: LocaleKeys.chatbot_intro_feature_care_desc,
    ),
    FeaturePoint(
      icon: Icons.language,
      background: const Color(0xFFEFF2FF),
      titleKey: LocaleKeys.chatbot_intro_feature_lang_title,
      descriptionKey: LocaleKeys.chatbot_intro_feature_lang_desc,
    ),
  ];
}

class FeaturePointCard extends StatelessWidget {
  const FeaturePointCard({super.key, required this.data});

  static const cardIcon = Color(0xFF2F80ED);

  final FeaturePoint data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: data.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            data.icon,
            size: 24,
            color: cardIcon,
          ),
        ),
        14.gap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.semiBold(data.title(), fontSize: 15),
              4.gap,
              AppText.regular(
                data.description(),
                fontSize: 13,
                color: UIColors.textBody,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
