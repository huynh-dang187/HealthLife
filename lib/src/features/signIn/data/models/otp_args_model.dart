class OtpArgs {
  final String verificationId;
  final String fullPhone;
  final int? resendToken;

  /// SĐT đã đăng ký hoàn tất profile -> sau xác thực về home luôn (đăng nhập lại).
  final bool isLogin;

  const OtpArgs({
    required this.verificationId,
    required this.fullPhone,
    this.resendToken,
    this.isLogin = false,
  });
}
