import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';

sealed class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

final class OtpInitial extends OtpState {}

final class OtpVerifying extends OtpState {}

final class OtpResending extends OtpState {}

final class OtpSuccess extends OtpState {}

final class OtpFailure extends OtpState {
  final String message;
  const OtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpVerificationCubit extends Cubit<OtpState> {
  final AuthRepository _repo;
  OtpVerificationCubit(this._repo) : super(OtpInitial());

  Future<void> verify({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(OtpVerifying());
    try {
      final user = await _repo.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      if (user != null) {
        emit(OtpSuccess());
      } else {
        emit(OtpInitial());
      }
    } catch (e) {
      emit(OtpFailure(_repo.mapAuthError(e)));
    }
  }

  Future<OtpChannel?> resend({
    required String fullPhone,
    required int resendToken,
  }) async {
    emit(OtpResending());
    try {
      return await _repo.resendOtp(
        phoneNumber: fullPhone,
        resendToken: resendToken,
      );
    } catch (e) {
      emit(OtpFailure(_repo.mapAuthError(e)));
      return null;
    }
  }
}
