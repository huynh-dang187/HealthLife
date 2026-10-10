import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/sos_device_repository.dart';
import '../../data/services/sos_notification_service.dart';
import 'sos_alert_state.dart';

/// ViewModel cho màn hình báo động khẩn cấp SOS.
///
/// Chịu trách nhiệm phát/tắt còi và gọi điện khẩn cấp.
class SosAlertCubit extends Cubit<SosAlertState> {
  SosAlertCubit(this._repo) : super(const SosAlertInitial());

  final SosDeviceRepository _repo;
  final AudioPlayer _player = AudioPlayer();

  /// Bắt đầu hú còi khẩn cấp (loop vô hạn).
  Future<void> startAlarm() async {
    emit(const SosAlertPlaying());
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/sos_sound.mp3'));
    } catch (_) {
      if (state is SosAlertPlaying) {
        if (!isClosed) emit(const SosAlertStopped());
      }
    }
  }

  /// Tắt còi và giải phóng resource.
  Future<void> stopAlarm() async {
    try {
      await _player.stop();
      await _player.release();
    } catch (_) {}
    await SosNotificationService.instance.cancelAlert();
    if (!isClosed) emit(const SosAlertStopped());
  }

  /// Mở app điện thoại mặc định và gọi số khẩn cấp.
  Future<void> callEmergency(String phoneNumber) async {
    final phone = phoneNumber.trim();
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Người nhận xác nhận đã xử lý cảnh báo: tắt còi và đánh dấu trên Firestore.
  Future<void> acknowledge(String? alertId) async {
    await stopAlarm();
    if (alertId == null || alertId.isEmpty) return;
    try {
      await _repo.acknowledgeAlert(alertId);
    } catch (e) {
      debugPrint('[SosAlert] acknowledge lỗi: $e');
    }
  }

  @override
  Future<void> close() async {
    try {
      await _player.stop();
      await _player.dispose();
    } catch (_) {}
    await super.close();
  }
}
