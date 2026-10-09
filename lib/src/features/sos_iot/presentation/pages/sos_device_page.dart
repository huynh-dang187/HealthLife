import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../data/models/sos_device.dart';
import '../../data/repositories/sos_device_repository.dart';

/// Hub "Thiết bị SOS": danh sách thiết bị đã kết nối của user.
class SosDevicePage extends StatelessWidget {
  const SosDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repo = SosDeviceRepository();

    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      appBar: AppAppBar(
        title: tr(LocaleKeys.sos_hub_title),
        centerTitle: true,
        rightBtns: [
          AppButton.widget(
            child: const Icon(
              Icons.add_circle_outline_rounded,
              color: UIColors.coral,
              size: 24,
            ),
            onTap: () => context.push(RouteNames.sos_device_pair),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<SosDevice>>(
          stream: repo.watchMyDevices(uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: AppText.medium(
                  tr(LocaleKeys.sos_pair_failed),
                  color: UIColors.textBody,
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final devices = snapshot.data!;
            if (devices.isEmpty) return const _SosEmptyView();

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              separatorBuilder: (context, index) => 12.gap,
              itemBuilder: (context, index) => _SosDeviceCard(
                device: devices[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SosEmptyView extends StatelessWidget {
  const _SosEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            48.gap,
            const Icon(
              Icons.sos,
              color: UIColors.coral,
              size: 72,
            ),
            16.gap,
            AppText.medium(
              tr(LocaleKeys.sos_hub_empty),
              color: UIColors.textBody,
              textAlign: TextAlign.center,
            ),
            24.gap,
            AppButton.fill(
              onTap: () => context.push(RouteNames.sos_device_pair),
              title: tr(LocaleKeys.sos_hub_add),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosDeviceCard extends StatelessWidget {
  const _SosDeviceCard({required this.device});

  final SosDevice device;

  @override
  Widget build(BuildContext context) {
    final lastText = device.lastTriggeredAt == null
        ? tr(LocaleKeys.sos_hub_never_triggered)
        : DateFormat('HH:mm dd/MM/yyyy').format(device.lastTriggeredAt!);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(
        RouteNames.sos_device_manage,
        extra: device.deviceId,
      ),
      child: Container(
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
                color: UIColors.coral.withAlpha(24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: UIColors.coral,
              ),
            ),
            12.gap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bold(device.deviceName, fontSize: 15),
                  6.gap,
                  Row(
                    children: [
                      const Icon(
                        Icons.battery_std,
                        size: 14,
                        color: UIColors.textBody,
                      ),
                      4.gap,
                      AppText.medium(
                        '${device.batteryLevel}%',
                        fontSize: 12,
                        color: UIColors.textBody,
                      ),
                    ],
                  ),
                  4.gap,
                  AppText.medium(
                    '${tr(LocaleKeys.sos_hub_last_trigger)}: $lastText',
                    fontSize: 12,
                    color: UIColors.textBody,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: UIColors.textBody),
          ],
        ),
      ),
    );
  }
}
