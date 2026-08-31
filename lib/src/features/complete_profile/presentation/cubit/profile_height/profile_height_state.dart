import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileHeightState {
  final BlocStatus status;
  final String? message;
  final int heightCm;
  final HeightUnit unit;
  final bool heightError;
  final String changeHeight;

  const ProfileHeightState({
    this.status = BlocStatus.initial,
    this.message,
    this.heightCm = 160,
    this.unit = HeightUnit.cm,
    this.heightError = false,
    this.changeHeight = '',
  });

  ProfileHeightState copyWith({
    BlocStatus? status,
    String? message,
    int? heightCm,
    HeightUnit? unit,
    bool? heightError,
    String? changeHeight,
  }) {
    return ProfileHeightState(
      status: status ?? this.status,
      message: message ?? this.message,
      heightCm: heightCm ?? this.heightCm,
      unit: unit ?? this.unit,
      heightError: heightError ?? this.heightError,
      changeHeight: changeHeight ?? this.changeHeight,
    );
  }
}
