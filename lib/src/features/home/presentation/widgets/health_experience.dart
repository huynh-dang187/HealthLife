import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';
import 'items/quiz_card.dart';

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
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _quizzes.length,
            separatorBuilder: (_, __) => 10.gap,
            itemBuilder: (context, index) => _quizzes[index],
          ),
        ),
      ],
    );
  }
}

final _quizzes = [
  const QuizCard(
    question: 'Mỗi ngày người trưởng thành nên uống bao nhiêu lít nước?',
    options: ['0.5 lít', '2.0 lít', '3.0 lít'],
    selectedIndex: 1,
  ),
  const QuizCard(
    question: 'Bạn nên đi bộ ít nhất bao nhiêu bước mỗi ngày?',
    options: ['3.000', '6.000', '10.000'],
    selectedIndex: 2,
  ),
  const QuizCard(
    question: 'Loại thực phẩm nào tốt cho tim mạch?',
    options: ['Cá hồi', 'Bánh kẹo', 'Nước ngọt'],
    selectedIndex: 0,
  ),
];
