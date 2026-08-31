import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';

class GreetingBanner extends StatelessWidget {
  const GreetingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.regular(
            'Xin chào',
            fontSize: 14,
            color: UIColors.black.withValues(alpha: 0.7),
          ),
          4.gap,
          AppText.bold('Huỳnh Nguyễn Đang', fontSize: 20),
          AppText.medium(
            'chào mừng bạn đến với HLIFE!',
            fontSize: 13,
            color: UIColors.black.withValues(alpha: 0.75),
          ),
          20.gap,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFDFE), Color(0xFFFFE1EC)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: UIColors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.semiBold(
                        'Mỗi ngày một lời khuyên',
                        fontSize: 14,
                        color: UIColors.pink,
                      ),
                      6.gap,
                      AppText.medium(
                        'Uống đủ 2 lít nước mỗi ngày bạn nhé',
                        fontSize: 13,
                        color: UIColors.text,
                      ),
                    ],
                  ),
                ),
                12.gap,
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: UIColors.pinkLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.water_drop_outlined,
                    size: 28,
                    color: UIColors.pink,
                  ),
                ),
              ],
            ),
          ),
          24.gap,
        ],
      ),
    );
  }
}
