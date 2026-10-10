import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';

import '../../data/repositories/sos_device_repository.dart';
import '../cubit/sos_pair_cubit.dart';
import '../cubit/sos_pair_state.dart';
import '../widgets/sos_pair/sos_confirm_create_dialog.dart';
import '../widgets/sos_pair/sos_pair_done_view.dart';
import '../widgets/sos_pair/sos_pair_form.dart';
import '../widgets/sos_pair/sos_pair_loading_view.dart';

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
    final ok = await showSosConfirmCreateDialog(context, state.deviceId);
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
                  SosPairLoading() => const SosPairLoadingView(),
                  SosPairDone(:final alreadyJoined) => SosPairDoneView(
                    deviceId: state.deviceId,
                    alreadyJoined: alreadyJoined,
                    onView: () => context.pop(),
                  ),
                  _ => SosPairForm(
                    controller: _codeController,
                    errorKey: state is SosPairError ? state.messageKey : null,
                    onSubmit: _submit,
                    onReset: () => context.read<SosPairCubit>().reset(),
                  ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
