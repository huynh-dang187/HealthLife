import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileHeightState {
  final BlocStatus status;
  final String? message;
  final int heightCm;
  final HeightUnit unit;

  const ProfileHeightState({
    this.status = BlocStatus.initial,
    this.message,
    this.heightCm = 160,
    this.unit = HeightUnit.cm,
  });

  ProfileHeightState copyWith({
    BlocStatus? status,
    String? message,
    int? heightCm,
    HeightUnit? unit,
  }) {
    return ProfileHeightState(
      status: status ?? this.status,
      message: message ?? this.message,
      heightCm: heightCm ?? this.heightCm,
      unit: unit ?? this.unit,
    );
  }
}
