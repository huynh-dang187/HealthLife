import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/enums/bloc_status.dart';
import '../../data/model/food_model.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/utils/nutrition_math.dart';
import 'food_search_state.dart';

class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit(this._repository) : super(const FoodSearchState());

  final NutritionRepository _repository;
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 400);

  /// Gõ tới đâu tìm tới đó: thay đổi query ngay, query API sau khi debounce.
  void onQueryChanged(String raw) {
    emit(state.copyWith(query: raw));
    _debounce?.cancel();

    final keyword = normalizeVietnamese(raw);
    if (keyword.isEmpty) {
      emit(state.copyWith(status: BlocStatus.initial, results: const []));
      return;
    }

    _debounce = Timer(_debounceDuration, () => _search(keyword));
  }

  Future<void> _search(String keyword) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final results = await _repository.searchFoods(keyword);
      emit(state.copyWith(status: BlocStatus.success, results: results));
    } catch (e) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          results: const [],
          error: e.toString(),
        ),
      );
    }
  }

  /// Thêm vào nhật ký (scale dinh dưỡng theo gram). Trả true nếu thành công.
  Future<bool> addToLog(FoodModel food, double grams) async {
    if (grams <= 0) return false;
    emit(state.copyWith(isAdding: true));
    try {
      await _repository.addMealLog(food: food, grams: grams);
      emit(state.copyWith(isAdding: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isAdding: false, error: e.toString()));
      return false;
    }
  }

  void clear() {
    _debounce?.cancel();
    emit(const FoodSearchState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}