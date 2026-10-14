import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

/// Avatar tròn hiển thị trong header drawer: ảnh mạng hoặc chữ cái đầu tên.
class DrawerAvatar extends StatelessWidget {
  const DrawerAvatar({super.key, required this.user, this.size = 54});

  final UserModel? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = user?.photoURL;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: UIColors.white, width: 2),
      ),
      child: ClipOval(
        child: (photo?.isNotEmpty ?? false)
            ? Image.network(
                photo!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Initials(user: user),
              )
            : _Initials(user: user),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final words = (user?.displayName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final text = words.isEmpty
        ? 'HL'
        : (words.length > 1
                  ? '${words.first[0]}${words[1][0]}'
                  : words.first[0])
              .toUpperCase();
    return Container(
      color: UIColors.pinkLight,
      alignment: Alignment.center,
      child: AppText.bold(text, fontSize: 20, color: UIColors.pink),
    );
  }
}
