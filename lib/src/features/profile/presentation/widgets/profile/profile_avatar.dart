import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final photo = user?.photoURL;
    final initials = _initials(user?.displayName?.trim() ?? '');

    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: UIColors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: (photo?.isNotEmpty ?? false)
            ? Image.network(
                photo!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Initials(initials),
              )
            : _Initials(initials),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UIColors.pinkLight,
      alignment: Alignment.center,
      child: AppText.bold(text, fontSize: 34, color: UIColors.pink),
    );
  }
}

String _initials(String name) {
  if (name.isEmpty) return 'HL';
  final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return 'HL';
  final first = words.first[0];
  final last = words.length > 1 ? words[1][0] : '';
  return (first + last).toUpperCase();
}
