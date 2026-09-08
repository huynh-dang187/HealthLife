import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';

class ProfileBanner extends StatelessWidget {
  const ProfileBanner({super.key, this.height = 240});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [UIColors.pinkLight, UIColors.pink],
        ),
      ),
    );
  }
}