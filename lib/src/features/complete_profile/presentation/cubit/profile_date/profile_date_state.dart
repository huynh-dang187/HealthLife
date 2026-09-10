import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileDateState {
  final BlocStatus status;
  final String? message;
  final bool dayError;
  final bool monthError;
  final bool yearError;

  const ProfileDateState({
    this.status = BlocStatus.initial,
    this.message,
    this.dayError = false,
    this.monthError = false,
    this.yearError = false,
  });

  ProfileDateState copyWith({
    BlocStatus? status,
    String? message,
    bool? dayError,
    bool? monthError,
    bool? yearError,
  }) {
    return ProfileDateState(
      status: status ?? this.status,
      message: message ?? this.message,
      dayError: dayError ?? this.dayError,
      monthError: monthError ?? this.monthError,
      yearError: yearError ?? this.yearError,
    );
  }
}
