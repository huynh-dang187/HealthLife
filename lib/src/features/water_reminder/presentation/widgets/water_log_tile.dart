import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';
import '../../data/models/water_log_model.dart';

class WaterLogTile extends StatelessWidget {
  final WaterLogModel log;
  final VoidCallback onDelete;

  const WaterLogTile({
    super.key,
    required this.log,
    required this.onDelete,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: UIColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: UIColors.separate,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE1F5FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop,
              color: Color(0xFF0288D1),
              size: 22,
            ),
          ),
          14.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  '${log.amount} ml',
                  fontSize: 16,
                  color: UIColors.text,
                ),
                2.gap,
                AppText.regular(
                  _formatTime(log.timestamp),
                  fontSize: 12,
                  color: UIColors.textBody,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: UIColors.error,
              size: 20,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: AppText.bold(
                    context.tr(LocaleKeys.water_reminder_delete_title),
                    fontSize: 18,
                  ),
                  content: AppText.regular(
                    context.tr(
                      LocaleKeys.water_reminder_delete_confirm,
                      namedArgs: {'amount': '${log.amount}'},
                    ),
                    fontSize: 14,
                    maxLines: 4,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: AppText.medium(
                        context.tr(LocaleKeys.water_reminder_cancel),
                        color: UIColors.textBody,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        onDelete();
                      },
                      child: AppText.bold(
                        context.tr(LocaleKeys.water_reminder_delete),
                        color: UIColors.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
