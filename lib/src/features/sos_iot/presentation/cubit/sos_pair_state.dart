sealed class SosPairState {
  const SosPairState();
}

/// Chưa nhập mã.
final class SosPairIdle extends SosPairState {
  const SosPairIdle();
}

/// Đang ghép nối (spinner).
final class SosPairLoading extends SosPairState {
  const SosPairLoading();
}

/// Ghép xong (thành công, hoặc đã nối trước đó).
final class SosPairDone extends SosPairState {
  const SosPairDone({
    required this.deviceId,
    required this.alreadyJoined,
  });

  final String deviceId;
  final bool alreadyJoined;
}

/// Ghép lỗi, kèm key thông báo đã localize.
final class SosPairError extends SosPairState {
  const SosPairError(this.messageKey);

  final String messageKey;
}