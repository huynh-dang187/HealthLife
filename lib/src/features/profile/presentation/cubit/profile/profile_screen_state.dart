import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileScreenState {
  final BlocStatus status;
  final String? message;

  const ProfileScreenState({
    this.status = BlocStatus.initial,
    this.message,
  });

  ProfileScreenState copyWith({
    BlocStatus? status,
    String? message,
  }) {
    return ProfileScreenState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}