import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';

sealed class GoogleSigninState extends Equatable {
  const GoogleSigninState();
  @override
  List<Object?> get props => [];
}

final class GoogleSigninInitial extends GoogleSigninState {}

final class GoogleSigninLoading extends GoogleSigninState {}

final class GoogleSigninSuccess extends GoogleSigninState {
  final bool profileCompleted;
  const GoogleSigninSuccess(this.profileCompleted);
  @override
  List<Object?> get props => [profileCompleted];
}

final class GoogleSigninFailure extends GoogleSigninState {
  final String message;
  const GoogleSigninFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class GoogleSigninCubit extends Cubit<GoogleSigninState> {
  final AuthRepository _authRepository;
  GoogleSigninCubit(this._authRepository) : super(GoogleSigninInitial());

  Future<void> signIn() async {
    emit(GoogleSigninLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        final completed = await _authRepository.isProfileCompleted(user.uid);
        emit(GoogleSigninSuccess(completed));
      } else {
        // Người dùng tự hủy, quay về trạng thái ban đầu, không coi là lỗi
        emit(GoogleSigninInitial());
      }
    } catch (e) {
      emit(GoogleSigninFailure(e.toString()));
    }
  }
}
