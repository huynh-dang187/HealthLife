import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileNameState {
  final BlocStatus status;
  final String? message;
  final String changeName;

  const ProfileNameState({
    this.status = BlocStatus.initial,
    this.message,
    this.changeName = '',
  });

  ProfileNameState copyWith({
    BlocStatus? status,
    String? message,
    String? changeName,
  }) {
    return ProfileNameState(
      status: status ?? this.status,
      message: message ?? this.message,
      changeName: changeName ?? this.changeName,
    );
  }
}
