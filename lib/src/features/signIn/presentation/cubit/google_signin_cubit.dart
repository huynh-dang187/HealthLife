import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/signIn/data/auth_repository.dart';

sealed class GoogleSigninState extends Equatable {
  const GoogleSigninState();
  @override
  List<Object?> get props => [];
}

final class GoogleSigninInitial extends GoogleSigninState {}

final class GoogleSigninLoading extends GoogleSigninState {}

final class GoogleSigninSuccess extends GoogleSigninState {}

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
        emit(GoogleSigninSuccess());
      } else {
        // Người dùng tự hủy, quay về trạng thái ban đầu, không coi là lỗi
        emit(GoogleSigninInitial());
      }
    } catch (e) {
      emit(GoogleSigninFailure(e.toString()));
    }
  }
}
