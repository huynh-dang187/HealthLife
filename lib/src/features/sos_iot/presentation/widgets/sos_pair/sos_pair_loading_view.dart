import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Trạng thái đang ghép nối (spinner).
class SosPairLoadingView extends StatelessWidget {
  const SosPairLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        48.gap,
        const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        24.gap,
        Center(
          child: AppText.medium(
            tr(LocaleKeys.sos_pair_pairing),
            color: UIColors.textBody,
          ),
        ),
      ],
    );
  }
}
