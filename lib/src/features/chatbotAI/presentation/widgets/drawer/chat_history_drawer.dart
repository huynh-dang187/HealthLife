import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/chatbotAI/data/models/chat_session_model.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/drawer_action_item.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/drawer_search_bar.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/rename_dialog.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/section_header.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/session_tile.dart';

class ChatHistoryDrawer extends StatefulWidget {
  const ChatHistoryDrawer({
    super.key,
    this.sessions = const [],
    this.onNewChat,
    this.onIntroTap,
    this.onSelectSession,
    this.onTogglePin,
    this.onRename,
    this.onDelete,
  });

  final List<ChatSessionModel> sessions;
  final VoidCallback? onNewChat;
  final VoidCallback? onIntroTap;
  final ValueChanged<ChatSessionModel>? onSelectSession;
  final void Function(ChatSessionModel session, bool pinned)? onTogglePin;
  final void Function(ChatSessionModel session, String newTitle)? onRename;
  final ValueChanged<ChatSessionModel>? onDelete;

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _rename(ChatSessionModel session) async {
    final newTitle = await showRenameDialog(context, session.title);
    if (newTitle == null || newTitle.isEmpty || !mounted) return;
    widget.onRename?.call(session, newTitle);
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _searchController.text.trim().toLowerCase();
    bool matches(ChatSessionModel s) =>
        keyword.isEmpty || s.title.toLowerCase().contains(keyword);

    final pinnedList = widget.sessions
        .where((s) => s.pinned && matches(s))
        .toList();
    final normalList = widget.sessions
        .where((s) => !s.pinned && matches(s))
        .toList();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: UIColors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            DrawerSearchBar(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onClose: () => Navigator.pop(context),
            ),
            16.gap,
            DrawerActionItem(
              icon: Icons.info_outline_rounded,
              title: LocaleKeys.chatbot_history_intro_bibi.tr(),
              onTap: () {
                Navigator.pop(context);
                widget.onIntroTap?.call();
              },
            ),
            12.gap,
            DrawerActionItem(
              icon: Icons.add_comment_outlined,
              title: LocaleKeys.chatbot_history_new_conversation.tr(),
              onTap: () {
                Navigator.pop(context);
                widget.onNewChat?.call();
              },
            ),
            20.gap,
            if (pinnedList.isNotEmpty) ...[
              SectionHeader(LocaleKeys.chatbot_history_pinned.tr()),
              8.gap,
              ...pinnedList.map((s) => _tile(s)),
              12.gap,
            ],
            ..._timedSections(normalList),
          ],
        ),
      ),
    );
  }

  Widget _tile(ChatSessionModel s) {
    return SessionTile(
      title: s.title,
      pinned: s.pinned,
      onTogglePin: () => widget.onTogglePin?.call(s, !s.pinned),
      onRename: () => _rename(s),
      onDelete: () => widget.onDelete?.call(s),
      onTap: () => widget.onSelectSession?.call(s),
    );
  }

  List<Widget> _timedSections(List<ChatSessionModel> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isToday(ChatSessionModel s) => !s.updatedAt.isBefore(today);
    bool inLast7Days(ChatSessionModel s) {
      final limit = today.subtract(const Duration(days: 7));
      return !s.updatedAt.isBefore(limit) && s.updatedAt.isBefore(today);
    }

    Widget section(String title, List<ChatSessionModel> list) {
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title),
          8.gap,
          ...list.map(_tile),
          12.gap,
        ],
      );
    }

    return [
      section(
        LocaleKeys.chatbot_history_today.tr(),
        sessions.where(isToday).toList(),
      ),
      section(
        LocaleKeys.chatbot_history_previous_7_days.tr(),
        sessions.where(inLast7Days).toList(),
      ),
    ];
  }
}
