import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sos_alert_state.dart';

/// ViewModel cho màn hình báo động khẩn cấp SOS.
///
/// Chịu trách nhiệm phát/tắt còi, gọi điện khẩn cấp và mở bản đồ.
class SosAlertCubit extends Cubit<SosAlertState> {
  SosAlertCubit() : super(const SosAlertInitial());

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
    if (!isClosed) emit(const SosAlertStopped());
  }

  /// Mở app điện thoại mặc định và gọi số khẩn cấp.
  Future<void> callEmergency(String phoneNumber) async {
    final phone = phoneNumber.trim();
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Mở Google Maps tại vị trí đã cho.
  Future<void> openMap(double lat, double lng) async {
    final uri = Uri(
      scheme: 'geo',
      queryParameters: {'q': '$lat,$lng'},
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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