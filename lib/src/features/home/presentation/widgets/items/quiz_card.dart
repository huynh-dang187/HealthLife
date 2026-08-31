import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.question,
    required this.options,
    required this.selectedIndex,
  });

  final String question;
  final List<String> options;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            question,
            fontSize: 13,
            maxLines: 2,
            color: UIColors.text,
          ),
          10.gap,
          for (var i = 0; i < options.length; i++) ...[
            _Option(label: options[i], selected: i == selectedIndex),
            if (i != options.length - 1) 4.gap,
          ],
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: selected
            ? UIColors.pink.withValues(alpha: 0.12)
            : UIColors.lightGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? UIColors.pink : Colors.transparent,
          width: 1,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: AppText.regular(
              label,
              fontSize: 11,
              color: selected ? UIColors.pink : UIColors.textBody,
              maxLines: 1,
            ),
          ),
          if (selected) ...[
            4.gap,
            Icon(Icons.check_circle, size: 14, color: UIColors.pink),
          ],
        ],
      ),
    );
  }
}
