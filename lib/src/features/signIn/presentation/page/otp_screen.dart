import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/signIn/data/models/otp_args_model.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';
import 'package:healthlife/src/features/signIn/presentation/cubit/otp/otp_verification_cubit.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.otpArgs});

  final OtpArgs otpArgs;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String _verificationId = widget.otpArgs.verificationId;
  late int? _resendToken = widget.otpArgs.resendToken;
  late final String _fullPhone = widget.otpArgs.fullPhone;

  late final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _goAfterAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final completed = doc.data()?['profileCompleted'] ?? false;
    if (!mounted) return;
    context.go(completed ? RouteNames.home : RouteNames.profile_name);
  }

  Future<void> _resend(OtpVerificationCubit cubit) async {
    final token = _resendToken;
    if (token == null) return;
    final channel = await cubit.resend(
      fullPhone: _fullPhone,
      resendToken: token,
    );
    if (!mounted) return;
    switch (channel) {
      case OtpCodeSent(:final verificationId, :final resendToken):
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
        });
        _startCountdown();
      case OtpAutoVerified():
        _goAfterAuth();
      default:
        break;
    }
  }

  void _verify(OtpVerificationCubit cubit) {
    if (_code.length != 6) return;
    cubit.verify(verificationId: _verificationId, smsCode: _code);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocProvider(
      create: (_) => OtpVerificationCubit(AuthRepository()),
      child: BlocConsumer<OtpVerificationCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpSuccess) {
            _goAfterAuth();
          } else if (state is OtpFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isVerifying = state is OtpVerifying;
          final isResending = state is OtpResending;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: AppText.bold('Xác nhận mã OTP', fontSize: 18),
            ),
            body: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: context.paddingBottomForButton,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  32.gap,
                  AppText.bold('Nhập mã xác nhận', fontSize: 22),
                  8.gap,
                  AppText.regular(
                    'Mã gồm 6 chữ số đã được gửi tới $_fullPhone',
                    fontSize: 13,
                    color: UIColors.textBody,
                  ),
                  32.gap,
                  Row(
                    children: [
                      for (var i = 0; i < 6; i++) ...[
                        if (i > 0) 8.gap,
                        Expanded(
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            enabled: !isVerifying,
                            autofocus: i == 0,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? UIColors.darkTextPrimary
                                  : UIColors.text,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: isDark
                                  ? UIColors.darkSurface
                                  : UIColors.lightGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: UIColors.pink,
                                ),
                              ),
                            ),
                            onChanged: (value) => _onDigitChanged(i, value),
                          ),
                        ),
                      ],
                    ],
                  ),
                  32.gap,
                  AppButton.fill(
                    enable: !isVerifying,
                    onTap: () => _verify(context.read<OtpVerificationCubit>()),
                    title: 'Xác nhận',
                    height: 50,
                    width: double.infinity,
                    titleWidget: isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  16.gap,
                  Center(
                    child: _seconds > 0
                        ? AppText.regular(
                            'Gửi lại mã sau ${_seconds}s',
                            fontSize: 13,
                            color: UIColors.textBody,
                          )
                        : TextButton(
                            onPressed: isResending
                                ? null
                                : () => _resend(
                                    context.read<OtpVerificationCubit>(),
                                  ),
                            child: AppText.medium(
                              'Gửi lại mã',
                              fontSize: 14,
                              color: UIColors.pink,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
