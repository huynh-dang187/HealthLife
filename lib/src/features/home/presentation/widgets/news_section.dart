import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/button.dart';
import '../../../../core/presentation/widgets/text.dart';
import 'items/news_card.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 12, top: 24),
          child: Row(
            children: [
              Expanded(
                child: AppText.semiBold(
                  'Bảng tin sức khỏe hôm nay',
                  fontSize: 16,
                ),
              ),
              AppButton.widget(
                onTap: () {},
                child: Row(
                  children: [
                    AppText.medium(
                      'Xem tất cả',
                      fontSize: 12,
                      color: UIColors.pink,
                    ),
                    2.gap,
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: UIColors.pink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        12.gap,
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _news.length,
            separatorBuilder: (_, __) => 10.gap,
            itemBuilder: (context, index) => _news[index],
          ),
        ),
      ],
    );
  }
}

final _news = [
  const NewsCard(
    title: '5 thói quen buổi sáng giúp bạn tràn đầy năng lượng cả ngày',
    source: 'HLIFE',
    time: '08:00',
    icon: Icons.wb_sunny_outlined,
  ),
  const NewsCard(
    title: 'Chế độ ăn giảm cân an toàn cho người ít tập luyện',
    source: 'Báo Sức Khỏe',
    time: '07:30',
    icon: Icons.restaurant_outlined,
  ),
  const NewsCard(
    title: 'Tại sao giấc ngủ sâu quan trọng với trí nhớ của bạn?',
    source: 'HLIFE',
    time: '06:45',
    icon: Icons.bedtime_outlined,
  ),
  const NewsCard(
    title: 'Tập yoga 10 phút mỗi ngày: lợi ích không ngờ',
    source: 'Chuyên gia',
    time: '05:20',
    icon: Icons.self_improvement,
  ),
];
