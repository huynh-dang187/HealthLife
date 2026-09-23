import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/drawer_action_item.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/drawer_search_bar.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/rename_dialog.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/section_header.dart';
import 'package:healthlife/src/features/chatbotAI/presentation/widgets/drawer/drawer_widget/session_tile.dart';

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
      if (!_pinned.remove(session.id)) _pinned.add(session.id);
    });
  }

  Future<void> _rename(ChatSessionItem session) async {
    final newTitle = await showRenameDialog(context, session.title);
    if (newTitle == null || newTitle.isEmpty || !mounted) return;
    final index = widget.sessions.indexWhere((s) => s.id == session.id);
    if (index == -1) return;
    setState(() {
      widget.sessions[index] = ChatSessionItem(
        id: session.id,
        title: newTitle,
        lastUpdate: session.lastUpdate,
        pinned: session.pinned,
      );
    });
  }

  void _delete(ChatSessionItem session) {
    setState(() {
      widget.sessions.removeWhere((s) => s.id == session.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyword = _searchController.text.trim().toLowerCase();
    bool matches(ChatSessionItem s) =>
        keyword.isEmpty || s.title.toLowerCase().contains(keyword);

    final pinnedList =
        widget.sessions.where((s) => _pinned.contains(s.id) && matches(s)).toList();
    final normalList =
        widget.sessions.where((s) => !_pinned.contains(s.id) && matches(s)).toList();

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
              ...pinnedList.map((s) => _tile(s, pinned: true)),
              12.gap,
            ],
            ..._timedSections(normalList),
          ],
        ),
      ),
    );
  }

  Widget _tile(ChatSessionItem s, {required bool pinned}) {
    return SessionTile(
      title: s.title,
      pinned: pinned,
      onTogglePin: () => _togglePin(s),
      onRename: () => _rename(s),
      onDelete: () => _delete(s),
      onTap: () => widget.onSelectSession?.call(s),
    );
  }

  List<Widget> _timedSections(List<ChatSessionItem> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isToday(ChatSessionItem s) => !s.lastUpdate.isBefore(today);
    bool inLast7Days(ChatSessionItem s) {
      final limit = today.subtract(const Duration(days: 7));
      return !s.lastUpdate.isBefore(limit) && s.lastUpdate.isBefore(today);
    }

    Widget section(String title, List<ChatSessionItem> list) {
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title),
          8.gap,
          ...list.map((s) => _tile(s, pinned: false)),
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