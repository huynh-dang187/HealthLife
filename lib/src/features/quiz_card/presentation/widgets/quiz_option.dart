import 'package:flutter/material.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/quiz_card/domains/enums/quiz_option.dart';

class QuizOption extends StatelessWidget {
  const QuizOption({super.key, required this.label, required this.state});

  final String label;
  final QuizOptionState state;

  @override
  Widget build(BuildContext context) {
    final checkColor = state.checkColor;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: state.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: state.borderColor, width: 1),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: AppText.regular(
              label,
              fontSize: 11,
              color: state.textColor,
              maxLines: 1,
            ),
          ),
          if (checkColor != null) ...[
            4.gap,
            Icon(Icons.check_circle, size: 14, color: checkColor),
          ],
        ],
      ),
    );
  }
}
