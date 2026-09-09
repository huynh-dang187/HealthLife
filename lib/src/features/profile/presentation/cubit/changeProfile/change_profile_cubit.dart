import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/models/user_model.dart';

import 'change_profile_state.dart';

class ChangeProfileCubit extends Cubit<ChangeProfileState> {
  ChangeProfileCubit(this._repository, {UserModel? user})
    : _initDisplayName = user?.displayName ?? '',
      _initGender = Gender.values.firstWhere(
        (g) => g.value == user?.gender,
        orElse: () => Gender.male,
      ),
      _initDob = user?.dateOfBirth,
      _initHeightCm = user?.height?.round() ?? 160,
      _initWeightKg = user?.weight ?? 50,
      super(ChangeProfileState.fromUser(user)) {
    _syncControllers();
  }

  final String _initDisplayName;
  final Gender _initGender;
  final DateTime? _initDob;
  final int _initHeightCm;
  final double _initWeightKg;

  /// Có thay đổi nào so với dữ liệu gốc trên Firestore hay không.
  bool get hasChanges {
    final dob = buildDate();
    final sameName = state.displayName.trim() == _initDisplayName.trim();
    final sameGender = state.gender == _initGender;
    final sameDob =
        (dob == null && _initDob == null) ||
        (dob != null &&
            _initDob != null &&
            dob.year == _initDob.year &&
            dob.month == _initDob.month &&
            dob.day == _initDob.day);
    final sameHeight = state.heightCm == _initHeightCm;
    final sameWeight = (state.weightKg - _initWeightKg).abs() < 0.001;
    return !(sameName && sameGender && sameDob && sameHeight && sameWeight);
  }

  static const double cmPerFt = 30.48;
  static const double lbsPerKg = 2.2046226218;
  static const int _cmMin = 100;
  static const int _cmMax = 250;
  static const int _ftMin = 30;
  static const int _ftMax = 277;
  static const double _weightMinKg = 20;
  static const double _weightMaxKg = 250;

  final ProfileRepository _repository;

  final nameController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  void _syncControllers() {
    nameController.text = state.displayName;
    dayController.text = state.day;
    monthController.text = state.month;
    yearController.text = state.year;
    _syncHeightText();
    _syncWeightText();
  }

  @override
  Future<void> close() {
    nameController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    heightController.dispose();
    weightController.dispose();
    return super.close();
  }

  // ---- Tên ----
  void onChangeName(String text) {
    emit(
      state.copyWith(
        displayName: text,
        nameError: text.trim().isEmpty,
      ),
    );
  }

  // ---- Giới tính ----
  void setGender(Gender gender) => emit(state.copyWith(gender: gender));

  // ---- Ngày sinh ----
  int daysInMonth(int year, int month) {
    final isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    const base = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return month == 2 && isLeap ? 29 : base[month];
  }

  DateTime? buildDate() {
    final d = int.tryParse(dayController.text.trim());
    final m = int.tryParse(monthController.text.trim());
    final y = int.tryParse(yearController.text.trim());
    if (d == null || m == null || y == null) return null;
    if (m < 1 || m > 12) return null;
    if (y < 1900 || y > DateTime.now().year) return null;
    if (d < 1 || d > daysInMonth(y, m)) return null;
    return DateTime(y, m, d);
  }

  void _crossValidateDay() {
    final d = int.tryParse(dayController.text);
    final m = int.tryParse(monthController.text);
    final y = int.tryParse(yearController.text);
    if (d == null || m == null || y == null) return;
    emit(state.copyWith(dayError: d > daysInMonth(y, m)));
  }

  void onChangeDay(String text) {
    final value = int.tryParse(text);
    if (text.isEmpty) {
      emit(state.copyWith(day: '', dayError: false));
      return;
    }
    if (value == null || value <= 0) {
      emit(state.copyWith(day: text, dayError: true));
      return;
    }
    emit(
      state.copyWith(
        day: text,
        dayError: false,
      ),
    );
    _crossValidateDay();
  }

  void onChangeMonth(String text) {
    final value = int.tryParse(text);
    if (text.isEmpty) {
      emit(state.copyWith(month: '', monthError: false));
      return;
    }
    if (value == null || value <= 0 || value > 12) {
      emit(state.copyWith(month: text, monthError: true));
      return;
    }
    emit(state.copyWith(month: text, monthError: false));
    _crossValidateDay();
  }

  void onChangeYear(String text) {
    final value = int.tryParse(text);
    final now = DateTime.now().year;
    if (text.isEmpty) {
      emit(state.copyWith(year: '', yearError: false));
      return;
    }
    if (value == null || value < 1900 || value > now) {
      emit(state.copyWith(year: text, yearError: true));
      return;
    }
    emit(state.copyWith(year: text, yearError: false));
    _crossValidateDay();
  }

  // ---- Chiều cao ----
  void onHeightTextChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(heightError: true));
      return;
    }
    final cm = _parseToCm(trimmed);
    emit(
      state.copyWith(
        heightCm: cm ?? state.heightCm,
        heightError: cm == null,
      ),
    );
  }

  void setHeightUnit(HeightUnit unit) {
    if (unit == state.heightUnit) return;
    final newMin = unit == HeightUnit.cm ? _cmMin : _ftMin;
    final newMax = unit == HeightUnit.cm ? _cmMax : _ftMax;
    emit(
      state.copyWith(
        heightUnit: unit,
        heightCm: state.heightCm.clamp(newMin, newMax),
        heightError: false,
      ),
    );
    _syncHeightText();
  }

  int? _parseToCm(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    if (state.heightUnit == HeightUnit.cm) {
      final cm = int.tryParse(trimmed);
      if (cm == null) return null;
      if (cm < _cmMin || cm > _cmMax) return null;
      return cm;
    }
    final ft = double.tryParse(trimmed);
    if (ft == null) return null;
    final cm = (ft * cmPerFt).round();
    if (cm < _ftMin || cm > _ftMax) return null;
    return cm;
  }

  void _syncHeightText() {
    final text = state.heightUnit == HeightUnit.cm
        ? state.heightCm.toString()
        : (state.heightCm / cmPerFt).toStringAsFixed(2);
    if (heightController.text == text) return;
    heightController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  // ---- Cân nặng ----
  void onWeightTextChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(weightError: true));
      return;
    }
    final kg = _parseToKg(trimmed);
    emit(
      state.copyWith(
        weightKg: kg ?? state.weightKg,
        weightError: kg == null,
      ),
    );
  }

  void setWeightUnit(WeightUnit unit) {
    if (unit == state.weightUnit) return;
    emit(state.copyWith(weightUnit: unit, weightError: false));
    _syncWeightText();
  }

  double? _parseToKg(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null || value <= 0) return null;
    final kg = state.weightUnit == WeightUnit.kg ? value : value / lbsPerKg;
    if (kg < _weightMinKg || kg > _weightMaxKg) return null;
    return kg;
  }

  void _syncWeightText() {
    final text = state.weightUnit == WeightUnit.kg
        ? _formatKg(state.weightKg)
        : _formatKg(state.weightKg * lbsPerKg);
    if (weightController.text == text) return;
    weightController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatKg(double value) {
    final s = value.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  // ---- Guard + lưu ----
  bool validate() {
    final dateOk = buildDate() != null;
    final nameOk = state.displayName.trim().isNotEmpty;
    final allOk =
        nameOk &&
        dateOk &&
        !state.dayError &&
        !state.monthError &&
        !state.yearError &&
        !state.heightError &&
        !state.weightError;
    emit(
      state.copyWith(
        nameError: !nameOk,
        status: allOk ? state.status : BlocStatus.initial,
      ),
    );
    return allOk;
  }

  Future<bool> saveChange() async {
    if (!validate()) return false;
    emit(state.copyWith(status: BlocStatus.loading, message: null));
    try {
      final date = buildDate();
      await _repository.updateDisplayName(state.displayName.trim());
      await _repository.updateDisplayGender(state.gender.value);
      if (date != null) {
        await _repository.updateDisplayDate(date);
      }
      await _repository.updateDisplayHeight(state.heightCm.toDouble());
      await _repository.updateDisplayWeight(state.weightKg);
      emit(state.copyWith(status: BlocStatus.success));
      return true;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: e.toString()));
      return false;
    }
  }
}