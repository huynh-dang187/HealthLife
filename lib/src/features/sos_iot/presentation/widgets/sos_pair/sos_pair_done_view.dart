import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Trạng thái ghép nối xong (thành công / đã nối trước đó).
class SosPairDoneView extends StatelessWidget {
  const SosPairDoneView({
    super.key,
    required this.deviceId,
    required this.alreadyJoined,
    required this.onView,
  });

  final String deviceId;
  final bool alreadyJoined;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        16.gap,
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: UIColors.green.withAlpha(24),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: UIColors.green,
              size: 36,
            ),
          ),
        ),
        20.gap,
        Center(
          child: AppText.bold(
            tr(
              alreadyJoined
                  ? LocaleKeys.sos_pair_already_joined
                  : LocaleKeys.sos_pair_success,
            ),
            fontSize: 18,
          ),
        ),
        12.gap,
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UIColors.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText.semiBold(
              deviceId,
              color: UIColors.textBody,
            ),
          ),
        ),
        40.gap,
        AppButton.fill(
          onTap: onView,
          title: tr(LocaleKeys.sos_pair_view_device),
          color: UIColors.green,
        ),
      ],
    );
  }
}
