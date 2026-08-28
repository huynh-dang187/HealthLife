import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_gender/profile_gender_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

class ProfileGenderCubit extends Cubit<ProfileGenderState> {
  final ProfileRepository _repository;
  ProfileGenderCubit(this._repository)
    : super(
        const ProfileGenderState(
          status: BlocStatus.initial,
        ),
      );

  Future<bool> saveGender(Gender gender) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _repository.updateDisplayGender(gender.value);
      emit(state.copyWith(status: BlocStatus.success, message: null));
      return true;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: e.toString()));
      return false;
    }
  }

  void selectGender(Gender gender) {
    emit(
      state.copyWith(
        selectedGender: gender,
      ),
    );
  }
}
