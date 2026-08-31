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
    emit(state.copyWith(heightCm: value, heightError: false));
    _syncText();
  }

  void onHeightTextChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(heightError: true));
      return;
    }
    final cm = _parseToCm(trimmed);
    if (cm == null) {
      emit(state.copyWith(heightError: true));
      return;
    }
    emit(
      state.copyWith(heightCm: cm, heightError: false),
    );
  }

  void setUnit(HeightUnit unit) {
    if (unit == state.unit) return;
    final newMax = unit == HeightUnit.cm ? _cmMax : _ftMax;
    final newMin = unit == HeightUnit.cm ? _cmMin : _ftMin;
    final clamped = state.heightCm.clamp(newMin, newMax);
    emit(
      state.copyWith(
        unit: unit,
        heightCm: clamped,
        heightError: false,
      ),
    );
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
      if (cm < minCm || cm > maxCm) {
        return null;
      }
      return cm;
    }
    final ft = double.tryParse(trimmed);
    if (ft == null) return null;
    final cm = (ft * cmPerFt).round();
    if (cm < minCm || cm > maxCm) return null; // ← chặn
    return cm;
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

  void onChangeHeight(String text) {
    emit(
      state.copyWith(
        changeHeight: text,
      ),
    );
  }
}
