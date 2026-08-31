import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'profile_name_state.dart';

class ProfileNameCubit extends Cubit<ProfileNameState> {
  final ProfileRepository _repository;
  ProfileNameCubit(this._repository)
    : super(const ProfileNameState(status: BlocStatus.initial));

  Future<bool> saveName(String name) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _repository.updateDisplayName(name.trim());
      emit(state.copyWith(status: BlocStatus.success, message: null));
      return true;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: e.toString()));
      return false;
    }
  }

  void onChangeName(String text) {
    emit(
      state.copyWith(
        changeName: text,
      ),
    );
  }
}
