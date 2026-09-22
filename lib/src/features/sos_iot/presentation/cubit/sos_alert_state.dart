/// Các trạng thái của màn hình báo động khẩn cấp SOS.
sealed class SosAlertState {
  const SosAlertState();
}

/// Trạng thái ban đầu khi màn hình chưa bắt đầu phát còi.
class SosAlertInitial extends SosAlertState {
  const SosAlertInitial();
}

/// Đang hú còi báo động.
class SosAlertPlaying extends SosAlertState {
  const SosAlertPlaying();
}

/// Đã tắt còi.
class SosAlertStopped extends SosAlertState {
  const SosAlertStopped();
}