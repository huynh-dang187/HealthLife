import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/core/infrastructure/repositories/user_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._userRepository) : super(const UserState());

  final UserRepository _userRepository;

  Future<void> loadUser() async {
    emit(const UserState(status: BlocStatus.loading));
    try {
      final user = await _userRepository.getCurrentUser();
      emit(UserState(status: BlocStatus.success, user: user));
    } catch (e) {
      emit(
        UserState(
          status: BlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  void clearUser() => emit(const UserState());
}
