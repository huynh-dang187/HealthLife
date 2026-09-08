import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

import 'profile_avatar.dart';
import 'profile_banner.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    const avatarSize = 104.0;
    final bannerHeight = context.screenHeight * 0.3;
    final name = user?.displayName?.trim();
    final displayName = (name?.isNotEmpty ?? false) ? name! : 'Thân mến';

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ProfileBanner(height: bannerHeight),
            Positioned(
              top: bannerHeight - avatarSize / 2,
              left: 0,
              right: 0,
              child: Center(child: ProfileAvatar(user: user)),
            ),
          ],
        ),
        (avatarSize / 2 + 16).gap,
        AppText.semiBold(displayName, fontSize: 22, color: UIColors.black),
        4.gap,
        AppText.regular(
          'Thành viên HLife',
          fontSize: 13,
          color: UIColors.textBody,
        ),
      ],
    );
  }
}