import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class PeriodNavRow extends StatelessWidget {
  const PeriodNavRow({
    super.key,
    required this.rangeLabel,
    required this.onPrev,
    required this.onNext,
  });

  final String rangeLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
          color: UIColors.text,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Center(
            child: AppText.semiBold(
              rangeLabel,
              fontSize: 15,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          color: UIColors.text,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}