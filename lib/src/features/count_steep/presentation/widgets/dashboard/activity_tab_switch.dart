import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../domains/enums/activity_tab.dart';

/// Segmented control 2 tab: Tổng quan / Lịch sử.
class ActivityTabSwitch extends StatelessWidget {
  const ActivityTabSwitch({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ActivityTab selected;
  final ValueChanged<ActivityTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: UIColors.lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            for (final tab in ActivityTab.values) ...[
              if (tab.index > 0) 4.gap,
              Expanded(
                child: _TabSwitchItem(
                  label: context.tr(tab.labelKey),
                  active: selected == tab,
                  onTap: () => onChanged(tab),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabSwitchItem extends StatelessWidget {
  const _TabSwitchItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? UIColors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Center(
            child: AppText.medium(
              label,
              fontSize: 13,
              color: active ? UIColors.white : UIColors.textBody,
            ),
          ),
        ),
      ),
    );
  }
}