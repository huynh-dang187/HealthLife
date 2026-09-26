import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/features/signIn/data/models/country_codes_model.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

sealed class PhoneInputState extends Equatable {
  const PhoneInputState();
  @override
  List<Object?> get props => [];
}

final class PhoneInputInitial extends PhoneInputState {
  final CountryCode country;
  const PhoneInputInitial(this.country);
  @override
  List<Object?> get props => [country];
}

final class PhoneInputSubmitting extends PhoneInputState {}

final class PhoneOtpSent extends PhoneInputState {
  final String verificationId;
  final String fullPhone;
  final int? resendToken;
  final bool isLogin;
  const PhoneOtpSent(
    this.verificationId,
    this.fullPhone,
    this.resendToken, {
    this.isLogin = false,
  });
  @override
  List<Object?> get props => [verificationId, fullPhone, resendToken, isLogin];
}

final class PhoneAutoSignedIn extends PhoneInputState {}

final class PhoneInputFailure extends PhoneInputState {
  final String message;
  const PhoneInputFailure(this.message);
  @override
  List<Object?> get props => [message];
}

final class PhoneDestination extends PhoneInputState {
  final String route;
  const PhoneDestination(this.route);
  @override
  List<Object?> get props => [route];
}

class PhoneInputCubit extends Cubit<PhoneInputState> {
  final AuthRepository _repo;
  PhoneInputCubit(this._repo) : super(PhoneInputInitial(kVietnamCountry));

  /// SĐT đã đăng ký xong profile rồi -> coi là đăng nhập lại, về home.
  bool _isLogin = false;

  void selectCountry(CountryCode country) {
    if (state is PhoneInputInitial) emit(PhoneInputInitial(country));
  }

  Future<void> sendOtp(String rawNumber) async {
    final current = state;
    if (current is! PhoneInputInitial) return;

    final fullPhone = _normalize(current.country.dialCode, rawNumber);
    if (fullPhone.length < 10 || fullPhone.length > 14) {
      emit(PhoneInputFailure(LocaleKeys.sign_in_invalid_phone.tr()));
      return;
    }

    emit(PhoneInputSubmitting());
    try {
      // SĐT đã đăng ký rồi -> vẫn gửi OTP, nhưng sau xác thực vào thẳng home
      // (không hỏi lại profile).
      final check = await _repo.checkPhoneRegistered(fullPhone);
      _isLogin = check.registered && check.profileCompleted;
      debugPrint(
        '[PhoneInputCubit] $fullPhone registered=${check.registered} '
        'profileCompleted=${check.profileCompleted} -> isLogin=$_isLogin',
      );

      final channel = await _repo.sendOtp(phoneNumber: fullPhone);
      switch (channel) {
        case OtpCodeSent(:final verificationId, :final resendToken):
          emit(
            PhoneOtpSent(
              verificationId,
              fullPhone,
              resendToken,
              isLogin: _isLogin,
            ),
          );
        case OtpAutoVerified():
          emit(PhoneAutoSignedIn());
      }
    } catch (e) {
      emit(PhoneInputFailure(_repo.mapAuthError(e)));
    }
  }

  Future<void> completeAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_isLogin) {
      emit(PhoneDestination(RouteNames.home));
      return;
    }
    final completed = await _repo.isProfileCompleted(user.uid);
    emit(
      PhoneDestination(
        completed ? RouteNames.home : RouteNames.profile_name,
      ),
    );
  }

  String _normalize(String dialCode, String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$dialCode$digits';
  }
}
