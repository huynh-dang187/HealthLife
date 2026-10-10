import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../../data/models/sos_user_info.dart';

/// Một dòng người nhận trong danh sách: tên + SĐT + nhãn "Tôi" + nút xoá.
class SosRecipientTile extends StatelessWidget {
  const SosRecipientTile({
    super.key,
    required this.nameFuture,
    required this.isMe,
    required this.onRemove,
  });

  final Future<SosUserInfo?> nameFuture;
  final bool isMe;
  final VoidCallback onRemove;

  static String _initial(String name) =>
      name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SosUserInfo?>(
      future: nameFuture,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final display =
            info?.displayName ?? tr(LocaleKeys.sos_manage_unknown_user);
        final phone = info?.phone ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: UIColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: UIColors.separate),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: UIColors.pinkLight,
                child: AppText.semiBold(
                  snapshot.connectionState == ConnectionState.waiting
                      ? '…'
                      : _initial(display),
                  color: UIColors.pink,
                ),
              ),
              12.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText.semiBold(display, fontSize: 14),
                        ),
                        if (isMe)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: UIColors.green.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AppText.semiBold(
                              tr(LocaleKeys.sos_manage_me),
                              fontSize: 11,
                              color: UIColors.green,
                            ),
                          ),
                      ],
                    ),
                    if (phone.isNotEmpty) ...[
                      2.gap,
                      AppText.medium(
                        phone,
                        fontSize: 12,
                        color: UIColors.textBody,
                      ),
                    ],
                  ],
                ),
              ),
              AppButton.widget(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: UIColors.coral,
                  size: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
