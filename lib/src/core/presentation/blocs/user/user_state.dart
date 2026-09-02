import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

final class UserState {
  final BlocStatus status;
  final String? message;
  final UserModel? user;

  const UserState({
    this.status = BlocStatus.initial,
    this.message,
    this.user,
  });

  UserState copyWith({
    BlocStatus? status,
    String? message,
    UserModel? user,
  }) {
    return UserState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }
}
