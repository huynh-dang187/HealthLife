import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

class ProfileGenderState {
  final BlocStatus status;
  final String? message;
  final Gender? selectedGender;

  const ProfileGenderState({
    this.status = BlocStatus.initial,
    this.message,
    this.selectedGender,
  });

  ProfileGenderState copyWith({
    BlocStatus? status,
    String? message,
    Gender? selectedGender,
  }) {
    return ProfileGenderState(
      status: status ?? this.status,
      message: message ?? this.message,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }
}
