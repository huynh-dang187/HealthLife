import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_weight/profile_weight_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

class ProfileWeightCubit extends Cubit<ProfileWeightState> {
  ProfileWeightCubit(this._repository) : super(const ProfileWeightState()) {
    _syncText();
  }

  static const double lbsPerKg = 2.2046226218;
  static const double minKg = 20;
  static const double maxKg = 250;

  final ProfileRepository _repository;
  final weightController = TextEditingController();

  @override
  Future<void> close() {
    weightController.dispose();
    return super.close();
  }

  void onWeightTextChanged(String text) {
    final kg = _parseToKg(text);
    if (kg == null || kg == state.weightKg) return;
    emit(state.copyWith(weightKg: kg));
  }

  void setUnit(WeightUnit unit) {
    if (unit == state.unit) return;
    emit(state.copyWith(unit: unit));
    _syncText();
  }

  Future<bool> saveWeight() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _repository.updateDisplayWeight(state.weightKg);
      await _repository.markProfileCompleted();
      emit(state.copyWith(status: BlocStatus.success, message: null));
      return true;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: e.toString()));
      return false;
    }
  }

  double? _parseToKg(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final value = double.tryParse(trimmed);
    if (value == null) return null;
    final kg = state.unit == WeightUnit.kg ? value : value / lbsPerKg;
    return kg.clamp(minKg, maxKg);
  }

  void _syncText() {
    final text = state.unit == WeightUnit.kg
        ? _format(state.weightKg)
        : _format(state.weightKg * lbsPerKg);
    if (weightController.text == text) return;
    weightController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _format(double value) {
    final s = value.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
