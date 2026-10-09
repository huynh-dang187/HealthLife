import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

import '../../data/repositories/sos_device_repository.dart';
import '../cubit/sos_pair_cubit.dart';
import '../cubit/sos_pair_state.dart';

/// SOS_01 — ghép nối thiết bị bằng mã in trên nút SOS.
/// SOS_03 — hiển thị kết quả ghép nối (thành công / đã nối trước đó / lỗi).
class SosPairPage extends StatelessWidget {
  const SosPairPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SosPairCubit(SosDeviceRepository()),
      child: const _SosPairView(),
    );
  }
}

class _SosPairView extends StatefulWidget {
  const _SosPairView();

  @override
  State<_SosPairView> createState() => _SosPairViewState();
}

class _SosPairViewState extends State<_SosPairView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<SosPairCubit>().pair(_codeController.text.trim());
  }

  /// Khi mã chưa tồn tại, hỏi xác nhận trước khi tạo thiết bị mới.
  Future<void> _onStateChanged(SosPairState state) async {
    if (state is! SosPairNotFound) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: UIColors.white,
        title: AppText.semiBold(
          tr(LocaleKeys.sos_pair_not_found_title),
          fontSize: 16,
        ),
        content: AppText.medium(
          tr(
            LocaleKeys.sos_pair_not_found_message,
            namedArgs: {'code': state.deviceId},
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText.medium(tr(LocaleKeys.sos_manage_cancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText.semiBold(
              tr(LocaleKeys.sos_pair_create_new),
              color: UIColors.coral,
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    final cubit = context.read<SosPairCubit>();
    if (ok == true) {
      await cubit.pair(state.deviceId, createIfMissing: true);
    } else {
      cubit.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      appBar: AppAppBar(
        title: tr(LocaleKeys.sos_pair_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<SosPairCubit, SosPairState>(
          listener: (context, state) => _onStateChanged(state),
          child: BlocBuilder<SosPairCubit, SosPairState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: switch (state) {
                  SosPairLoading() => _buildPairing(),
                  SosPairDone(:final alreadyJoined) => _buildDone(
                    context,
                    state.deviceId,
                    alreadyJoined,
                  ),
                  _ => _buildForm(context, state),
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPairing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        48.gap,
        const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
        24.gap,
        Center(
          child: AppText.medium(
            tr(LocaleKeys.sos_pair_pairing),
            color: UIColors.textBody,
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context, String deviceId, bool alreadyJoined) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        16.gap,
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: UIColors.green.withAlpha(24),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: UIColors.green,
              size: 36,
            ),
          ),
        ),
        20.gap,
        Center(
          child: AppText.bold(
            tr(
              alreadyJoined
                  ? LocaleKeys.sos_pair_already_joined
                  : LocaleKeys.sos_pair_success,
            ),
            fontSize: 18,
          ),
        ),
        12.gap,
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UIColors.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText.semiBold(
              deviceId,
              color: UIColors.textBody,
            ),
          ),
        ),
        40.gap,
        AppButton.fill(
          onTap: () => context.pop(),
          title: tr(LocaleKeys.sos_pair_view_device),
          color: UIColors.green,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, SosPairState state) {
    final errorKey = state is SosPairError ? state.messageKey : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.medium(
          tr(LocaleKeys.sos_pair_subtitle),
          color: UIColors.textBody,
        ),
        24.gap,
        AppText.semiBold(tr(LocaleKeys.sos_pair_code_label)),
        8.gap,
        AppTF.common(
          controller: _codeController,
          hintText: LocaleKeys.sos_pair_code_hint,
          onSubmitted: (_) => _submit(),
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
            LengthLimitingTextInputFormatter(
              SosDeviceRepository.maxDeviceCodeLength,
            ),
          ],
          textColor: errorKey != null ? UIColors.error : null,
        ),
        if (errorKey != null) ...[
          10.gap,
          AppText.medium(
            tr(errorKey),
            color: UIColors.error,
            fontSize: 13,
          ),
        ],
        24.gap,
        AppButton.fill(
          onTap: _submit,
          title: tr(LocaleKeys.sos_pair_button),
        ),
        if (errorKey != null) ...[
          12.gap,
          AppButton.outline(
            onTap: () => context.read<SosPairCubit>().reset(),
            title: tr(LocaleKeys.sos_pair_try_again),
          ),
        ],
      ],
    );
  }
}
