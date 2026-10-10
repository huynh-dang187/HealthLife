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
import '../widgets/sos_device/sos_device_card.dart';
import '../widgets/sos_device/sos_device_empty_view.dart';

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
            if (devices.isEmpty) {
              return SosDeviceEmptyView(
                onAdd: () => context.push(RouteNames.sos_device_pair),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              separatorBuilder: (context, index) => 12.gap,
              itemBuilder: (context, index) => SosDeviceCard(
                device: devices[index],
                onTap: () => context.push(
                  RouteNames.sos_device_manage,
                  extra: devices[index].deviceId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
