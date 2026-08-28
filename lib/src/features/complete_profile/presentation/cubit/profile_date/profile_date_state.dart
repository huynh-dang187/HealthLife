import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileDateState {
  final BlocStatus status;
  final String? message;

  const ProfileDateState({
    this.status = BlocStatus.initial,
    this.message,
  });

  ProfileDateState copyWith({
    BlocStatus? status,
    String? message,
  }) {
    return ProfileDateState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
