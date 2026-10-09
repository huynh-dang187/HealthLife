import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/sos_device_repository.dart';
import 'sos_pair_state.dart';

class SosPairCubit extends Cubit<SosPairState> {
  SosPairCubit(this._repo) : super(const SosPairIdle());

  final SosDeviceRepository _repo;

  /// Ghép nối bằng mã thiết bị (nhập tay).
  Future<void> pair(String rawCode) async {
    emit(const SosPairLoading());
    try {
      final status = await _repo.pair(rawCode);
      if (status == SosPairStatus.deviceFull) {
        emit(const SosPairError('sos_pair_device_full'));
        return;
      }
      emit(
        SosPairDone(
          deviceId: SosDeviceRepository.normalizeDeviceCode(rawCode),
          alreadyJoined: status == SosPairStatus.alreadyJoined,
        ),
      );
    } on FormatException {
      emit(const SosPairError('sos_pair_invalid_code'));
    } catch (e) {
      debugPrint('[SosPair] pair lỗi: $e');
      emit(const SosPairError('sos_pair_failed'));
    }
  }

  /// Về trạng thái nhập lại mã.
  void reset() => emit(const SosPairIdle());
}