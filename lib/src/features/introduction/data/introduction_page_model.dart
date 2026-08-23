import 'package:healthlife/generated/assets.gen.dart';

class IntroductionPageModel {
  final AssetGenImage backgroundImage;
  final String description;
  final List<FloatingCardModel>? floatingCards;

  const IntroductionPageModel({
    required this.backgroundImage,
    required this.description,
    this.floatingCards,
  });
}

class FloatingCardModel {
  final String icon;
  final String? label;
  final double top;
  final double right;

  const FloatingCardModel({
    required this.icon,
    this.label,
    required this.top,
    required this.right,
  });
}
