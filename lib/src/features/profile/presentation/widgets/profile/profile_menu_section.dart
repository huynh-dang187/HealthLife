import 'package:flutter/material.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: AppText.semiBold(title, fontSize: 16),
        ),
        12.gap,
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) 10.gap,
          items[i],
        ],
      ],
    );
  }
}
