import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/signIn/data/models/country_codes_model.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';

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
  const PhoneOtpSent(this.verificationId, this.fullPhone, this.resendToken);

  @override
  List<Object?> get props => [verificationId, fullPhone, resendToken];
}

final class PhoneAutoSignedIn extends PhoneInputState {}

final class PhoneInputFailure extends PhoneInputState {
  final String message;
  const PhoneInputFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PhoneInputCubit extends Cubit<PhoneInputState> {
  final AuthRepository _repo;
  PhoneInputCubit(this._repo) : super(PhoneInputInitial(kVietnamCountry));

  void selectCountry(CountryCode country) {
    if (state is PhoneInputInitial) emit(PhoneInputInitial(country));
  }

  Future<void> sendOtp(String rawNumber) async {
    final current = state;
    if (current is! PhoneInputInitial) return;

    final fullPhone = _normalize(current.country.dialCode, rawNumber);
    if (fullPhone.length < 10 || fullPhone.length > 14) {
      emit(PhoneInputFailure('Số điện thoại không hợp lệ'));
      return;
    }

    emit(PhoneInputSubmitting());
    try {
      final channel = await _repo.sendOtp(phoneNumber: fullPhone);
      switch (channel) {
        case OtpCodeSent(:final verificationId, :final resendToken):
          emit(PhoneOtpSent(verificationId, fullPhone, resendToken));
        case OtpAutoVerified():
          emit(PhoneAutoSignedIn());
      }
    } catch (e) {
      emit(PhoneInputFailure(_repo.mapAuthError(e)));
    }
  }

  String _normalize(String dialCode, String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$dialCode$digits';
  }
}
