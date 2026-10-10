import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

/// Trạng thái rỗng của hub khi user chưa kết nối thiết bị nào.
class SosDeviceEmptyView extends StatelessWidget {
  const SosDeviceEmptyView({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            48.gap,
            const Icon(Icons.sos, color: UIColors.coral, size: 72),
            16.gap,
            AppText.medium(
              tr(LocaleKeys.sos_hub_empty),
              color: UIColors.textBody,
              textAlign: TextAlign.center,
            ),
            24.gap,
            AppButton.fill(
              onTap: onAdd,
              title: tr(LocaleKeys.sos_hub_add),
            ),
          ],
        ),
      ),
    );
  }
}
