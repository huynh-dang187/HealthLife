class OtpArgs {
  final String verificationId;
  final String fullPhone;
  final int? resendToken;

  const OtpArgs({
    required this.verificationId,
    required this.fullPhone,
    this.resendToken,
  });
}
