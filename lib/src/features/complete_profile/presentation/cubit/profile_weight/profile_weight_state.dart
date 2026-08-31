import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileWeightState {
  const ProfileWeightState({
    this.status = BlocStatus.initial,
    this.message,
    this.weightKg = 65,
    this.unit = WeightUnit.kg,
  });

  final BlocStatus status;
  final String? message;
  final double weightKg;
  final WeightUnit unit;

  ProfileWeightState copyWith({
    BlocStatus? status,
    String? message,
    double? weightKg,
    WeightUnit? unit,
  }) {
    return ProfileWeightState(
      status: status ?? this.status,
      message: message ?? this.message,
      weightKg: weightKg ?? this.weightKg,
      unit: unit ?? this.unit,
    );
  }
}
