import 'dart:io';
import '../../../../shared/enums/bloc_status.dart';
import '../../data/models/food_nutrition_model.dart';

class FoodScanState {
  final BlocStatus status;
  final File? selectedImage;
  final FoodNutritionModel? nutritionResult;
  final String? errorMessage;

  const FoodScanState({
    this.status = BlocStatus.initial,
    this.selectedImage,
    this.nutritionResult,
    this.errorMessage,
  });

  bool get isLoading => status == BlocStatus.loading;

  FoodScanState copyWith({
    BlocStatus? status,
    File? selectedImage,
    FoodNutritionModel? nutritionResult,
    String? errorMessage,
  }) {
    return FoodScanState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      nutritionResult: nutritionResult ?? this.nutritionResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}