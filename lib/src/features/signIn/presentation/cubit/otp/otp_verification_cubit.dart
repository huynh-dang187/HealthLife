import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

sealed class OtpState extends Equatable {
  const OtpState();
  @override
  List<Object?> get props => [];
}

final class OtpInitial extends OtpState {}

final class OtpVerifying extends OtpState {}

final class OtpResending extends OtpState {}

final class OtpResent extends OtpState {
  final String verificationId;
  final int? resendToken;
  const OtpResent(this.verificationId, this.resendToken);
  @override
  List<Object?> get props => [verificationId, resendToken];
}

final class OtpSuccess extends OtpState {}

final class OtpDestination extends OtpState {
  final String route;
  const OtpDestination(this.route);
  @override
  List<Object?> get props => [route];
}

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
    if (FirebaseAuth.instance.currentUser != null) {
      emit(OtpSuccess());
      return;
    }
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

  Future<void> resend({
    required String fullPhone,
    required int resendToken,
  }) async {
    emit(OtpResending());
    try {
      final channel = await _repo.resendOtp(
        phoneNumber: fullPhone,
        resendToken: resendToken,
      );
      switch (channel) {
        case OtpCodeSent(:final verificationId, :final resendToken):
          emit(OtpResent(verificationId, resendToken));
        case OtpAutoVerified():
          emit(OtpSuccess());
      }
    } catch (e) {
      emit(OtpFailure(_repo.mapAuthError(e)));
    }
  }

  Future<void> completeAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final completed = await _repo.isProfileCompleted(user.uid);
    emit(
      OtpDestination(
        completed ? RouteNames.home : RouteNames.profile_name,
      ),
    );
  }
}
