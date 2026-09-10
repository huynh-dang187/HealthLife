import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

final class ChangeProfileState {
  final BlocStatus status;
  final String? message;
  final String displayName;
  final Gender gender;
  final String day;
  final String month;
  final String year;
  final bool dayError;
  final bool monthError;
  final bool yearError;
  final bool nameError;
  final bool heightError;
  final bool weightError;
  final int heightCm;
  final HeightUnit heightUnit;
  final double weightKg;
  final WeightUnit weightUnit;

  const ChangeProfileState({
    this.status = BlocStatus.initial,
    this.message,
    this.displayName = '',
    this.gender = Gender.male,
    this.day = '',
    this.month = '',
    this.year = '',
    this.dayError = false,
    this.monthError = false,
    this.yearError = false,
    this.nameError = false,
    this.heightError = false,
    this.weightError = false,
    this.heightCm = 160,
    this.heightUnit = HeightUnit.cm,
    this.weightKg = 50,
    this.weightUnit = WeightUnit.kg,
  });

  factory ChangeProfileState.fromUser(UserModel? user) {
    final dob = user?.dateOfBirth;
    return ChangeProfileState(
      displayName: user?.displayName ?? '',
      gender: Gender.values.firstWhere(
        (g) => g.value == user?.gender,
        orElse: () => Gender.male,
      ),
      day: dob != null ? dob.day.toString() : '',
      month: dob != null ? dob.month.toString() : '',
      year: dob != null ? dob.year.toString() : '',
      heightCm: user?.height?.round() ?? 160,
      weightKg: user?.weight ?? 50,
    );
  }

  ChangeProfileState copyWith({
    BlocStatus? status,
    String? message,
    String? displayName,
    Gender? gender,
    String? day,
    String? month,
    String? year,
    bool? dayError,
    bool? monthError,
    bool? yearError,
    bool? nameError,
    bool? heightError,
    bool? weightError,
    int? heightCm,
    HeightUnit? heightUnit,
    double? weightKg,
    WeightUnit? weightUnit,
  }) {
    return ChangeProfileState(
      status: status ?? this.status,
      message: message ?? this.message,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
      dayError: dayError ?? this.dayError,
      monthError: monthError ?? this.monthError,
      yearError: yearError ?? this.yearError,
      nameError: nameError ?? this.nameError,
      heightError: heightError ?? this.heightError,
      weightError: weightError ?? this.weightError,
      heightCm: heightCm ?? this.heightCm,
      heightUnit: heightUnit ?? this.heightUnit,
      weightKg: weightKg ?? this.weightKg,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }
}