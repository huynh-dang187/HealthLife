import '../datasources/nutrition_remote_data_source.dart';
import '../model/daily_target_model.dart';
import '../model/food_model.dart';
import '../model/meal_log_model.dart';

class NutritionRepository {
  NutritionRepository(this._remoteDataSource);

  final NutritionRemoteDataSource _remoteDataSource;

  Future<List<FoodModel>> searchFoods(String keyword) {
    return _remoteDataSource.searchFoods(keyword);
  }

  Future<List<MealLogModel>> getMealLogsInRange(
    DateTime start,
    DateTime end,
  ) {
    return _remoteDataSource.getMealLogsInRange(start, end);
  }

  Future<MealLogModel> addMealLog({
    required FoodModel food,
    required double grams,
    DateTime? mealTime,
  }) {
    return _remoteDataSource.addMealLog(food: food, grams: grams, mealTime: mealTime);
  }

  Future<void> deleteMealLog(String logId) {
    return _remoteDataSource.deleteMealLog(logId);
  }

  Future<DailyTargetModel> fetchDailyTargets() {
    return _remoteDataSource.fetchDailyTargets();
  }
}