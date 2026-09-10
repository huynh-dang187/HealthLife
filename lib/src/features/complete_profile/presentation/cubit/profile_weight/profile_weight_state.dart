import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class ProfileWeightState {
  const ProfileWeightState({
    this.status = BlocStatus.initial,
    this.message,
    this.weightKg = 65,
    this.unit = WeightUnit.kg,
    this.weightError = false,
  });

  final BlocStatus status;
  final String? message;
  final double weightKg;
  final WeightUnit unit;
  final bool weightError;

  ProfileWeightState copyWith({
    BlocStatus? status,
    String? message,
    double? weightKg,
    WeightUnit? unit,
    bool? weightError,
  }) {
    return ProfileWeightState(
      status: status ?? this.status,
      message: message ?? this.message,
      weightKg: weightKg ?? this.weightKg,
      unit: unit ?? this.unit,
      weightError: weightError ?? this.weightError,
    );
  }
}
