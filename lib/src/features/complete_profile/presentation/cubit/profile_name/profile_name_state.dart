import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileNameState {
  final BlocStatus status;
  final String? message;

  const ProfileNameState({
    this.status = BlocStatus.initial,
    this.message,
  });

  ProfileNameState copyWith({BlocStatus? status, String? message}) {
    return ProfileNameState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
