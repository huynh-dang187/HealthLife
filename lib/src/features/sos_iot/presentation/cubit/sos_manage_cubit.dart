import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/sos_device_repository.dart';
import 'sos_manage_state.dart';

class SosManageCubit extends Cubit<SosManageState> {
  SosManageCubit(this._repo) : super(const SosManageIdle());

  final SosDeviceRepository _repo;

  /// Thêm người nhận bằng SĐT (tìm user trong `users` rồi mời vào nhóm).
  /// Trả `true` nếu thành công.
  Future<bool> addRecipientByPhone({
    required String deviceId,
    required List<String> currentRecipients,
    required String rawPhone,
  }) async {
    emit(const SosManageBusy(SosManageAction.addRecipient));
    try {
      if (currentRecipients.length >= SosDeviceRepository.maxRecipients) {
        emit(const SosManageError('sos_manage_device_full'));
        return false;
      }
      final user = await _repo.searchUserByPhone(rawPhone);
      if (user == null) {
        emit(const SosManageError('sos_manage_user_not_found'));
        return false;
      }
      if (currentRecipients.contains(user.uid)) {
        emit(const SosManageError('sos_manage_already_added'));
        return false;
      }
      await _repo.addRecipient(deviceId, user.uid);
      emit(const SosManageIdle());
      return true;
    } on StateError {
      emit(const SosManageError('sos_manage_device_full'));
      return false;
    } catch (e) {
      debugPrint('[SosManage] addRecipient lỗi: $e');
      emit(const SosManageError('sos_pair_failed'));
      return false;
    }
  }

  /// Xoá một thành viên khỏi danh sách người nhận. Trả `true` nếu thành công.
  Future<bool> removeRecipient(String deviceId, String targetUid) async {
    emit(const SosManageBusy(SosManageAction.removeRecipient));
    try {
      await _repo.removeRecipient(deviceId, targetUid);
      emit(const SosManageIdle());
      return true;
    } catch (e) {
      debugPrint('[SosManage] removeRecipient lỗi: $e');
      emit(const SosManageError('sos_pair_failed'));
      return false;
    }
  }

  /// Rời khỏi thiết bị (gỡ mình khỏi danh sách nhận). Trả `true` nếu thành công.
  Future<bool> leave(String deviceId) async {
    emit(const SosManageBusy(SosManageAction.leave));
    try {
      await _repo.leave(deviceId);
      emit(const SosManageIdle());
      return true;
    } catch (e) {
      debugPrint('[SosManage] leave lỗi: $e');
      emit(const SosManageError('sos_pair_failed'));
      return false;
    }
  }

  /// Sửa tên thiết bị / SĐT khẩn cấp. Trả `true` nếu thành công.
  Future<bool> updateDeviceSettings({
    required String deviceId,
    required String deviceName,
    String? emergencyPhone,
  }) async {
    emit(const SosManageBusy(SosManageAction.editDevice));
    try {
      await _repo.updateDeviceSettings(
        deviceId,
        deviceName: deviceName,
        emergencyPhone: emergencyPhone,
      );
      emit(const SosManageIdle());
      return true;
    } catch (e) {
      debugPrint('[SosManage] updateDeviceSettings lỗi: $e');
      emit(const SosManageError('sos_pair_failed'));
      return false;
    }
  }
}