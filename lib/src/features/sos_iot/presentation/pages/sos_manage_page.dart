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
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../data/models/sos_alert_record.dart';
import '../../data/models/sos_device.dart';
import '../../data/models/sos_user_info.dart';
import '../../data/repositories/sos_device_repository.dart';
import '../cubit/sos_manage_cubit.dart';
import '../cubit/sos_manage_state.dart';

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

  Future<void> _showAddDialog(
    SosManageCubit cubit,
    SosDevice device,
  ) async {
    final controller = TextEditingController();
    final resolved = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: UIColors.white,
        title: AppText.semiBold(
          tr(LocaleKeys.sos_manage_add_recipient),
          fontSize: 16,
        ),
        content: SizedBox(
          height: 46,
          child: AppTF.common(
            controller: controller,
            hintText: LocaleKeys.sos_manage_phone_hint,
            keyboardType: TextInputType.phone,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText.medium(
              tr(LocaleKeys.sos_manage_cancel),
              fontSize: 14,
              color: UIColors.textBody,
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (dialogContext, value, _) => AppButton.fill(
              onTap: () => Navigator.pop(dialogContext, value.text.trim()),
              title: tr(LocaleKeys.sos_manage_confirm),
              enable: value.text.trim().isNotEmpty,
            ),
          ),
        ],
      ),
    );

    final phone = resolved?.trim() ?? '';
    if (phone.isEmpty) return;
    await cubit.addRecipientByPhone(
      deviceId: widget.deviceId,
      currentRecipients: device.recipientIds,
      rawPhone: phone,
    );
  }

  Future<void> _showEditDialog(SosManageCubit cubit, SosDevice device) async {
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => _EditDeviceDialog(device: device),
    );
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
                  _buildHeader(cubit, device, recipients.length),
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
                    (uid) => _RecipientTile(
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
                  if (recipients.length < SosDeviceRepository.maxRecipients) ...[
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
                  _AlertsHistory(repo: _repo, deviceId: widget.deviceId),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SosManageCubit cubit, SosDevice device, int count) {
    final online = device.isOnline;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UIColors.separate),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: UIColors.coral.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sos, color: UIColors.coral),
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(device.deviceName, fontSize: 16),
                4.gap,
                NameTag(
                  online: online,
                  labelKey: online
                      ? LocaleKeys.sos_hub_online
                      : LocaleKeys.sos_hub_offline,
                ),
              ],
            ),
          ),
          AppText.bold(
            '$count/${SosDeviceRepository.maxRecipients}',
            fontSize: 15,
            color: UIColors.green,
          ),
          AppButton.widget(
            onTap: () => _showEditDialog(cubit, device),
            child: const Icon(
              Icons.edit_outlined,
              color: UIColors.textBody,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => AppText.semiBold(text, fontSize: 16);
}

/// Tag nhỏ "Trực tuyến / Ngoại tuyến" của thiết bị.
class NameTag extends StatelessWidget {
  const NameTag({super.key, required this.online, required this.labelKey});

  final bool online;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: online ? UIColors.green : UIColors.dustyRose,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        AppText.medium(
          tr(labelKey),
          fontSize: 12,
          color: UIColors.textBody,
        ),
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({
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
        final display = info?.displayName ?? 'Người dùng';
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
                      : _RecipientTile._initial(display),
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
                              'Tôi',
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

class _AlertsHistory extends StatelessWidget {
  const _AlertsHistory({required this.repo, required this.deviceId});

  final SosDeviceRepository repo;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SosAlertRecord>>(
      stream: repo.watchAlerts(deviceId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppText.medium(
            tr(LocaleKeys.sos_pair_failed),
            color: UIColors.textBody,
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final alerts = snapshot.data!;
        if (alerts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: AppText.medium(
                tr(LocaleKeys.sos_manage_no_alerts),
                color: UIColors.textBody,
              ),
            ),
          );
        }
        return Column(
          children: alerts
              .map(
                (a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: UIColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UIColors.separate),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: UIColors.coral,
                        size: 20,
                      ),
                      12.gap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.semiBold(
                              tr(LocaleKeys.sos_manage_alert_triggered),
                              fontSize: 14,
                            ),
                            2.gap,
                            AppText.medium(
                              DateFormat('HH:mm dd/MM/yyyy')
                                  .format(a.triggeredAt),
                              fontSize: 12,
                              color: UIColors.textBody,
                            ),
                            6.gap,
                            _StatusChip(
                              acknowledged: a.isAcknowledged,
                            ),
                          ],
                        ),
                      ),
                      AppText.medium(
                        '${a.batteryLevel}%',
                        fontSize: 12,
                        color: UIColors.textBody,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Nhãn trạng thái xử lý của một cảnh báo.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.acknowledged});

  final bool acknowledged;

  @override
  Widget build(BuildContext context) {
    final color = acknowledged ? UIColors.green : UIColors.coral;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AppText.semiBold(
        tr(
          acknowledged
              ? LocaleKeys.sos_manage_alert_acknowledged
              : LocaleKeys.sos_manage_alert_pending,
        ),
        fontSize: 11,
        color: color,
      ),
    );
  }
}

/// Dialog sửa tên thiết bị + SĐT khẩn cấp.
///
/// Tự quản [TextEditingController] và dispose đúng vòng đời để tránh
/// lỗi deactivate InheritedElement khi dialog đang đóng.
/// Trả về `(deviceName, emergencyPhone)` khi lưu, `null` khi huỷ.
class _EditDeviceDialog extends StatefulWidget {
  const _EditDeviceDialog({required this.device});

  final SosDevice device;

  @override
  State<_EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<_EditDeviceDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.device.deviceName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.device.emergencyPhone ?? '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    Navigator.pop(context, (name, phone.isEmpty ? null : phone));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UIColors.white,
      title: AppText.semiBold(
        tr(LocaleKeys.sos_manage_edit_device),
        fontSize: 16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.medium(
            tr(LocaleKeys.sos_manage_device_name),
            fontSize: 13,
            color: UIColors.textBody,
          ),
          8.gap,
          AppTF.common(
            controller: _nameController,
            hintText: LocaleKeys.sos_manage_device_name,
          ),
          16.gap,
          AppText.medium(
            tr(LocaleKeys.sos_manage_emergency_phone),
            fontSize: 13,
            color: UIColors.textBody,
          ),
          8.gap,
          AppTF.common(
            controller: _phoneController,
            hintText: LocaleKeys.sos_manage_emergency_phone_hint,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: AppText.medium(
            tr(LocaleKeys.sos_manage_cancel),
            fontSize: 14,
            color: UIColors.textBody,
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _nameController,
          builder: (context, value, _) => AppButton.fill(
            onTap: _save,
            title: tr(LocaleKeys.sos_manage_save),
            enable: value.text.trim().isNotEmpty,
          ),
        ),
      ],
    );
  }
}