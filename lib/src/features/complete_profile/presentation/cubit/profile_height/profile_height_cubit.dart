import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_height/profile_height_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

class ProfileHeightCubit extends Cubit<ProfileHeightState> {
  ProfileHeightCubit(this._repository) : super(const ProfileHeightState()) {
    _syncText();
  }
  static const double cmPerFt = 30.48;
  static const int _cmMin = 100;
  static const int _cmMax = 250;
  static const int _ftMin = 30; // round(1 * 30.48)
  static const int _ftMax = 277; // round(9.1 * 30.48)

  int get minCm => state.unit == HeightUnit.cm ? _cmMin : _ftMin;
  int get maxCm => state.unit == HeightUnit.cm ? _cmMax : _ftMax;
  final ProfileRepository _repository;
  final heightController = TextEditingController();

  @override
  Future<void> close() {
    heightController.dispose();
    return super.close();
  }

  void selectHeight(int cm) {
    final value = cm.clamp(minCm, maxCm);
    if (value == state.heightCm) return;
    emit(state.copyWith(heightCm: value));
    _syncText();
  }

  void onHeightTextChanged(String text) {
    final cm = _parseToCm(text);
    if (cm == null || cm == state.heightCm) return;
    emit(state.copyWith(heightCm: cm));
  }

  void setUnit(HeightUnit unit) {
    if (unit == state.unit) return;
    emit(state.copyWith(unit: unit));
    _syncText();
  }

  Future<bool> saveHeight() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _repository.updateDisplayHeight(state.heightCm.toDouble());
      emit(state.copyWith(status: BlocStatus.success, message: null));
      return true;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: e.toString()));
      return false;
    }
  }

  int? _parseToCm(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    if (state.unit == HeightUnit.cm) {
      final cm = int.tryParse(trimmed);
      if (cm == null) return null;
      return cm.clamp(minCm, maxCm);
    }
    final ft = double.tryParse(trimmed);
    if (ft == null) return null;
    return (ft * cmPerFt).round().clamp(minCm, maxCm);
  }

  void _syncText() {
    final text = state.unit == HeightUnit.cm
        ? state.heightCm.toString()
        : (state.heightCm / cmPerFt).toStringAsFixed(2);
    if (heightController.text == text) return;
    heightController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
