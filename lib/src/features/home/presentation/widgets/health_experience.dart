import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';
import '../../../../features/quiz_card/presentation/widgets/daily_quiz_carousel.dart';

class HealthExperience extends StatelessWidget {
  const HealthExperience({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 24),
          child: AppText.semiBold('Trải nghiệm sức khỏe hôm nay', fontSize: 16),
        ),
        6.gap,
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: AppText.regular(
            'Cùng kiểm tra kiến thức sức khỏe của bạn',
            fontSize: 12,
            color: UIColors.textBody,
          ),
        ),
        12.gap,
        const DailyQuizCarousel(),
      ],
    );
  }
}
