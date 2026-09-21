import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'activity_dashboard_state.dart';

class ActivityDashboardCubit extends Cubit<ActivityDashboardState> {
  ActivityDashboardCubit(
    this._repository, {
    UserCubit? userCubit,
  }) : _userCubit = userCubit,
       super(const ActivityDashboardState());

  final ActivityRepository _repository;
  final UserCubit? _userCubit;

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

      final storedGoal = await _repository.fetchStoredStepGoal();
      final goal = storedGoal ?? await _resolveDefaultGoal();
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

  /// Tính mục tiêu mặc định từ hồ sơ user và ghi `users/{uid}.stepGoal` LẦN ĐẦU.
  Future<int> _resolveDefaultGoal() async {
    final user = _userCubit?.state.user;
    final calculated = await _repository.calculateDefaultGoal(user);
    await _repository.updateStepGoal(calculated);
    debugPrint(
      '[ActivityCubit] khởi tạo mục tiêu mặc định stepGoal=$calculated',
    );
    return calculated;
  }

  /// Lưu mục tiêu mới lên Firestore rồi tải lại goal/streak để UI cập nhật ngay.
  Future<void> updateStepGoal(int goal) async {
    try {
      await _repository.updateStepGoal(goal);
      if (!isClosed) {
        emit(state.copyWith(stepGoal: goal));
      }
      await refresh();
    } catch (e) {
      debugPrint('[ActivityCubit] updateStepGoal failed: $e');
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