import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

class ChatSessionItem {
  const ChatSessionItem({
    required this.id,
    required this.title,
    required this.lastUpdate,
    this.pinned = false,
  });

  final int id;
  final String title;
  final DateTime lastUpdate;
  final bool pinned;
}

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({
    super.key,
    this.sessions = const [],
    this.onNewChat,
    this.onIntroTap,
    this.onSelectSession,
  });

  final List<ChatSessionItem> sessions;
  final VoidCallback? onNewChat;
  final VoidCallback? onIntroTap;
  final ValueChanged<ChatSessionItem>? onSelectSession;

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  final _searchController = TextEditingController();
  late final Set<int> _pinned;

  @override
  void initState() {
    super.initState();
    _pinned = widget.sessions.where((s) => s.pinned).map((s) => s.id).toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _togglePin(ChatSessionItem session) {
    setState(() {
      if (!_pinned.remove(session.id)) {
        _pinned.add(session.id);
      }
    });
  }

  Future<void> _renameSession(
    BuildContext context,
    ChatSessionItem session,
  ) async {
    final controller = TextEditingController(text: session.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UIColors.white,
        title: AppText.semiBold(
          LocaleKeys.chatbot_history_rename_title.tr(),
          fontSize: 16,
        ),
        content: SizedBox(
          height: 46,
          child: AppTF.common(
            controller: controller,
            hintText: session.title,
            height: 46,
            borderCicular: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(context),
            child: AppText.medium(
              LocaleKeys.chatbot_history_cancel.tr(),
              fontSize: 14,
              color: UIColors.textBody,
            ),
          ),
          AppButton.fill(
            onTap: () => context.pop(context),
            title: LocaleKeys.chatbot_history_rename.tr(),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {});
    }
  }

  void _deleteSession(ChatSessionItem session) {
    setState(() {
      widget.sessions.removeWhere((s) => s.id == session.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _searchController.text.trim().toLowerCase();
    bool matches(ChatSessionItem s) =>
        keyword.isEmpty || s.title.toLowerCase().contains(keyword);

    final pinnedList = widget.sessions
        .where((s) => _pinned.contains(s.id) && matches(s))
        .toList();
    final normalList = widget.sessions
        .where((s) => !_pinned.contains(s.id) && matches(s))
        .toList();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: UIColors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AppTF.common(
                      controller: _searchController,
                      hintText: LocaleKeys.chatbot_history_search_hint,
                      height: 40,
                      borderCicular: 20,
                      bgColor: const Color(0xFFF3F8F5),
                      textColor: UIColors.text,
                      leftWidget: Assets.svg.iconSearch.svg(
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          UIColors.textBody,
                          BlendMode.srcIn,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),
            16.gap,
            _DrawerAction(
              icon: Icons.info_outline_rounded,
              title: LocaleKeys.chatbot_history_intro_bibi.tr(),
              onTap: () {
                context.pop(context);
                widget.onIntroTap?.call();
              },
            ),
            12.gap,
            _DrawerAction(
              icon: Icons.add_comment_outlined,
              title: LocaleKeys.chatbot_history_new_conversation.tr(),
              onTap: () {
                context.pop(context);
                widget.onNewChat?.call();
              },
            ),
            20.gap,
            if (pinnedList.isNotEmpty) ...[
              _SectionHeader(LocaleKeys.chatbot_history_pinned.tr()),
              8.gap,
              ...pinnedList.map(
                (s) => _SessionTileView(
                  session: s,
                  pinned: true,
                  onTogglePin: () => _togglePin(s),
                  onRename: () => _renameSession(context, s),
                  onDelete: () => _deleteSession(s),
                  onTap: () => widget.onSelectSession?.call(s),
                ),
              ),
              12.gap,
            ],
            ..._buildTimedSections(normalList),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimedSections(List<ChatSessionItem> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isToday(ChatSessionItem s) => !s.lastUpdate.isBefore(today);
    bool inLast7Days(ChatSessionItem s) {
      final limit = today.subtract(const Duration(days: 7));
      return !s.lastUpdate.isBefore(limit) && s.lastUpdate.isBefore(today);
    }

    final parts = <Widget>[];
    void addGroup(String section, List<ChatSessionItem> list) {
      if (list.isEmpty) return;
      parts.add(_SectionHeader(section));
      parts.add(8.gap);
      parts.addAll(
        list.map(
          (s) => _SessionTileView(
            session: s,
            pinned: false,
            onTogglePin: () => _togglePin(s),
            onRename: () => _renameSession(context, s),
            onDelete: () => _deleteSession(s),
            onTap: () => widget.onSelectSession?.call(s),
          ),
        ),
      );
      parts.add(12.gap);
    }

    addGroup(
      LocaleKeys.chatbot_history_today.tr(),
      sessions.where(isToday).toList(),
    );
    addGroup(
      LocaleKeys.chatbot_history_previous_7_days.tr(),
      sessions.where(inLast7Days).toList(),
    );
    return parts;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText.semiBold(title, fontSize: 13, color: UIColors.textBody);
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1FBF67)),
          ),
          12.gap,
          AppText.semiBold(title, fontSize: 14, color: UIColors.text),
        ],
      ),
    );
  }
}

class _SessionTileView extends StatelessWidget {
  const _SessionTileView({
    required this.session,
    required this.pinned,
    required this.onTogglePin,
    required this.onRename,
    required this.onDelete,
    required this.onTap,
  });

  final ChatSessionItem session;
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
              child: AppText.medium(
                session.title,
                fontSize: 14,
                color: UIColors.text,
                maxLines: 1,
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
            PopupMenuButton<_SessionMenuAction>(
              color: UIColors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (action) {
                switch (action) {
                  case _SessionMenuAction.rename:
                    onRename();
                  case _SessionMenuAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _SessionMenuAction.rename,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: UIColors.text,
                      ),
                      8.gap,
                      AppText.medium(
                        LocaleKeys.chatbot_history_rename.tr(),
                        fontSize: 13,
                        color: UIColors.text,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _SessionMenuAction.delete,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFE8434F),
                      ),
                      8.gap,
                      AppText.medium(
                        LocaleKeys.chatbot_history_delete.tr(),
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

enum _SessionMenuAction { rename, delete }
