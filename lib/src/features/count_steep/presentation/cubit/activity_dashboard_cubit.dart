import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'activity_dashboard_state.dart';

class ActivityDashboardCubit extends Cubit<ActivityDashboardState> {
  ActivityDashboardCubit(this._repository) : super(const ActivityDashboardState());

  final ActivityRepository _repository;

  StreamSubscription<int>? _stepSub;

  /// Xin quyền → đọc goal/streak → lắng nghe stream bước chân thật.
  Future<void> start() async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final granted = await _repository.requestActivityPermission();
      if (!granted) {
        emit(
          state.copyWith(
            status: BlocStatus.failure,
            permissionGranted: false,
            error: 'Chưa được cấp quyền truy cập cảm biến bước chân',
          ),
        );
        return;
      }

      final goal = await _repository.fetchStepGoal();
      final streak = await _repository.fetchCurrentStreak();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            permissionGranted: true,
            stepGoal: goal,
            streak: streak.currentStreak,
            bestStreak: streak.bestStreak,
            error: null,
          ),
        );
      }

      await _stepSub?.cancel();
      _stepSub = _repository.getSensorStepStream().listen(
        (today) {
          if (!isClosed) {
            emit(
              state.copyWith(
                status: BlocStatus.success,
                permissionGranted: true,
                todaySteps: today,
                error: null,
              ),
            );
          }
          _repository.saveTodayStepsToFirestore(today);
        },
        onError: (Object error) {
          debugPrint('[ActivityCubit] sensor stream error: $error');
          if (!isClosed) {
            emit(state.copyWith(status: BlocStatus.failure, error: '$error'));
          }
        },
        onDone: () => debugPrint('[ActivityCubit] sensor stream done'),
      );
    } catch (e, st) {
      debugPrint('[ActivityCubit] start failed: $e\n$st');
      if (!isClosed) {
        emit(state.copyWith(status: BlocStatus.failure, error: '$e'));
      }
    }
  }

  /// Tải lại goal/streak từ Firestore (giữ nguyên số bước đang chạy).
  Future<void> refresh() async {
    try {
      final goal = await _repository.fetchStepGoal();
      final streak = await _repository.fetchCurrentStreak();
      if (!isClosed) {
        emit(
          state.copyWith(
            stepGoal: goal,
            streak: streak.currentStreak,
            bestStreak: streak.bestStreak,
          ),
        );
      }
    } catch (e) {
      debugPrint('[ActivityCubit] refresh failed: $e');
    }
  }

  @override
  Future<void> close() async {
    await _stepSub?.cancel();
    await super.close();
  }
}