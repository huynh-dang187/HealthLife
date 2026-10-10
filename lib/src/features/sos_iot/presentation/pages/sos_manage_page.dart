import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../data/models/sos_device.dart';
import '../../data/repositories/sos_device_repository.dart';
import '../cubit/sos_manage_cubit.dart';
import '../cubit/sos_manage_state.dart';
import '../widgets/sos_manage/sos_add_recipient_sheet.dart';
import '../widgets/sos_manage/sos_alerts_history.dart';
import '../widgets/sos_manage/sos_edit_device_sheet.dart';
import '../widgets/sos_manage/sos_manage_header.dart';
import '../widgets/sos_manage/sos_recipient_tile.dart';

/// SOS_04 — danh sách người nhận (≤3) + lịch sử cảnh báo của 1 thiết bị.
class SosManagePage extends StatelessWidget {
  const SosManagePage({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SosManageCubit(SosDeviceRepository()),
      child: _SosManageView(deviceId: deviceId),
    );
  }
}

class _SosManageView extends StatefulWidget {
  const _SosManageView({required this.deviceId});

  final String deviceId;

  @override
  State<_SosManageView> createState() => _SosManageViewState();
}

class _SosManageViewState extends State<_SosManageView> {
  late final SosDeviceRepository _repo = SosDeviceRepository();

  String get _me => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> _confirm(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: AppText.medium(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText.medium(tr(LocaleKeys.sos_manage_cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText.semiBold(
              tr(LocaleKeys.sos_manage_confirm),
              color: UIColors.coral,
            ),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _showAddDialog(SosManageCubit cubit, SosDevice device) async {
    final phone = await showSosAddRecipientSheet(context);
    final trimmed = phone?.trim() ?? '';
    if (trimmed.isEmpty) return;
    await cubit.addRecipientByPhone(
      deviceId: widget.deviceId,
      currentRecipients: device.recipientIds,
      rawPhone: trimmed,
    );
  }

  Future<void> _showEditDialog(SosManageCubit cubit, SosDevice device) async {
    final result = await showSosEditDeviceSheet(context, device);
    if (result == null) return;

    final ok = await cubit.updateDeviceSettings(
      deviceId: widget.deviceId,
      deviceName: result.$1,
      emergencyPhone: result.$2,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(LocaleKeys.sos_manage_saved)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SosManageCubit>();

    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      appBar: AppAppBar(
        title: tr(LocaleKeys.sos_manage_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<SosManageCubit, SosManageState>(
          listener: (context, state) {
            if (state is SosManageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr(state.messageKey)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: StreamBuilder<SosDevice?>(
            stream: _repo.watchDevice(widget.deviceId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: AppText.medium(
                    tr(LocaleKeys.sos_pair_failed),
                    color: UIColors.textBody,
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final device = snapshot.data!;
              final recipients = device.recipientIds;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SosManageHeader(
                    device: device,
                    count: recipients.length,
                    onEdit: () => _showEditDialog(cubit, device),
                  ),
                  20.gap,
                  _sectionTitle(
                    tr(
                      LocaleKeys.sos_manage_recipients_title,
                      namedArgs: {'count': '${recipients.length}'},
                    ),
                  ),
                  10.gap,
                  if (recipients.isEmpty)
                    AppText.medium(
                      tr(LocaleKeys.sos_hub_empty),
                      color: UIColors.textBody,
                    ),
                  ...recipients.map(
                    (uid) => SosRecipientTile(
                      nameFuture: _repo.fetchUser(uid),
                      isMe: uid == _me,
                      onRemove: () async {
                        if (!await _confirm(
                          tr(LocaleKeys.sos_manage_remove_confirm),
                        )) {
                          return;
                        }
                        final removed = await cubit.removeRecipient(
                          widget.deviceId,
                          uid,
                        );
                        if (removed && context.mounted && uid == _me) {
                          context.pop(); // Rời thiết bị này quay về hub.
                        }
                      },
                    ),
                  ),
                  if (recipients.length <
                      SosDeviceRepository.maxRecipients) ...[
                    10.gap,
                    AppButton.outline(
                      onTap: () => _showAddDialog(cubit, device),
                      title: tr(LocaleKeys.sos_manage_add_recipient),
                    ),
                  ],
                  8.gap,
                  TextButton(
                    onPressed: () async {
                      if (!await _confirm(
                        tr(LocaleKeys.sos_manage_leave_confirm),
                      )) {
                        return;
                      }
                      final left = await cubit.leave(widget.deviceId);
                      if (left && context.mounted) {
                        context.pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: UIColors.coral.withAlpha(10),
                    ),
                    child: AppText.semiBold(
                      tr(LocaleKeys.sos_manage_leave),
                      color: UIColors.coral,
                    ),
                  ),
                  24.gap,
                  _sectionTitle(tr(LocaleKeys.sos_manage_alerts_title)),
                  10.gap,
                  SosAlertsHistory(repo: _repo, deviceId: widget.deviceId),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => AppText.semiBold(text, fontSize: 16);
}
