import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/daily_tips/data/repositories/daily_tip_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'daily_tip_state.dart';

class DailyTipCubit extends Cubit<DailyTipState> {
  DailyTipCubit(this._repository) : super(const DailyTipState());

  final DailyTipRepository _repository;

  Future<void> loadTip() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final tip = await _repository.getTodayTip();
      emit(
        state.copyWith(
          status: BlocStatus.success,
          tip: tip,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
