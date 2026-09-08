import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'profile_screen_state.dart';

class ProfileScreenCubit extends Cubit<ProfileScreenState> {
  ProfileScreenCubit() : super(const ProfileScreenState());

  Future<void> logout() async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        message: null,
      ),
    );
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
      emit(
        state.copyWith(
          status: BlocStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
