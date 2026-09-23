import 'package:flutter/material.dart';
import 'package:healthlife/generated/fonts.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

enum SessionMenuAction { rename, delete }

class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.title,
    required this.pinned,
    required this.onTogglePin,
    required this.onRename,
    required this.onDelete,
    this.onTap,
  });

  final String title;
  final bool pinned;
  final VoidCallback onTogglePin;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: UIColors.text,
                  fontFamily: FontFamily.inter,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTogglePin,
              child: Icon(
                pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 17,
                color: pinned
                    ? const Color(0xFF1FBF67)
                    : UIColors.textBody.withValues(alpha: 120),
              ),
            ),
            4.gap,
            PopupMenuButton<SessionMenuAction>(
              color: UIColors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (action) {
                Navigator.of(context).pop();
                switch (action) {
                  case SessionMenuAction.rename:
                    onRename();
                  case SessionMenuAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SessionMenuAction.rename,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: UIColors.text,
                      ),
                      8.gap,
                      AppText.medium(
                        LocaleKeys.chatbot_history_rename,
                        fontSize: 13,
                        color: UIColors.text,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: SessionMenuAction.delete,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFE8434F),
                      ),
                      8.gap,
                      AppText.medium(
                        LocaleKeys.chatbot_history_delete,
                        fontSize: 13,
                        color: const Color(0xFFE8434F),
                      ),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: UIColors.textBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
