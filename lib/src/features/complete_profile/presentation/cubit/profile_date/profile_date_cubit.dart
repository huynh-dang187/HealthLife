import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_date/profile_date_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

class ProfileDateCubit extends Cubit<ProfileDateState> {
  ProfileDateCubit(this._repository)
    : super(
        const ProfileDateState(
          status: BlocStatus.initial,
        ),
      );

  final ProfileRepository _repository;

  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();

  @override
  Future<void> close() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    return super.close();
  }

  bool get isValid => buildDate() != null;

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

  int daysInMonth(int year, int month) {
    final isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    const base = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return month == 2 && isLeap ? 29 : base[month];
  }

  Future<bool> saveDate() async {
    final date = buildDate();
    if (date == null) return false;
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      await _repository.updateDisplayDate(date);
      emit(state.copyWith(status: BlocStatus.success, message: null));
      return true;
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, message: e.toString()));
      return false;
    }
  }
}
