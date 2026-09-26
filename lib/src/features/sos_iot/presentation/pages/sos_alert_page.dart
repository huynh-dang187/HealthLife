import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/sos_iot/data/models/sos_alert_args.dart';

import '../cubit/sos_alert_cubit.dart';
import '../cubit/sos_alert_state.dart';
import '../widgets/sos_alert_action_buttons.dart';
import '../widgets/sos_alert_info_card.dart';
import '../widgets/sos_hero_pulse.dart';

/// Màn hình báo động khẩn cấp SOS (full-screen, nền đỏ đậm).
///
/// Tự cung cấp [SosAlertCubit] — mở ở bất kỳ đâu bằng:
/// ```dart
/// context.push(RouteNames.sos_alert, extra: const SosAlertArgs());
/// ```
class SosAlertPage extends StatelessWidget {
  const SosAlertPage({super.key, this.args = const SosAlertArgs()});

  final SosAlertArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SosAlertCubit(),
      child: _SosAlertView(args: args),
    );
  }
}

class _SosAlertView extends StatefulWidget {
  const _SosAlertView({required this.args});

  final SosAlertArgs args;

  @override
  State<_SosAlertView> createState() => _SosAlertViewState();
}

class _SosAlertViewState extends State<_SosAlertView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _scale = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _fade = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SosAlertCubit>().startAlarm();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _timeText => widget.args.triggeredAt == null
      ? DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now())
      : DateFormat('HH:mm dd/MM/yyyy').format(widget.args.triggeredAt!);

  Future<void> _onCallEmergency(SosAlertCubit cubit) async {
    final phone = await _promptPhone();
    if (phone == null || phone.isEmpty) return;
    if (!mounted) return;
    await cubit.callEmergency(phone);
  }

  Future<String?> _promptPhone() {
    final controller = TextEditingController(
      text: widget.args.emergencyPhone,
    );
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText.semiBold(
          context.tr(LocaleKeys.sos_call_emergency),
          fontSize: 17,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.tr(LocaleKeys.sign_in_phone_hint),
            prefixIcon: const Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText.medium(
              context.tr(LocaleKeys.profile_cancel),
              fontSize: 14,
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: AppText.semiBold(
              context.tr(LocaleKeys.sos_call),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onStopAlarm(SosAlertCubit cubit) async {
    await cubit.stopAlarm();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocListener<SosAlertCubit, SosAlertState>(
        listener: (context, state) {
          if (state is SosAlertStopped) _pulseController.stop();
        },
        child: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(),
                  SosHeroPulse(scale: _scale, opacity: _fade),
                  40.gap,
                  AppText.bold(
                    context.tr(LocaleKeys.sos_alert_title),
                    fontSize: 26,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  16.gap,
                  SosAlertInfoCard(
                    deviceName: widget.args.deviceName,
                    batteryLevel: widget.args.batteryLevel,
                    time: _timeText,
                  ),
                  const Spacer(),
                  SosAlertActionButtons(
                    onStop: () => _onStopAlarm(context.read<SosAlertCubit>()),
                    onCall: () =>
                        _onCallEmergency(context.read<SosAlertCubit>()),
                    onMap: () async {
                      final cubit = context.read<SosAlertCubit>();
                      await cubit.openMap(
                        widget.args.latitude,
                        widget.args.longitude,
                      );
                    },
                  ),
                  8.gap,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}