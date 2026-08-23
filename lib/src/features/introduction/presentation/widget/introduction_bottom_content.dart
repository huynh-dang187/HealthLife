import 'package:flutter/material.dart';
import 'package:healthlife/src/features/introduction/data/introduction_page_model.dart';

class IntroductionPageItem extends StatelessWidget {
  final IntroductionPageModel data;
  const IntroductionPageItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [data.backgroundImage.image(fit: BoxFit.cover)],
    );
  }
}
