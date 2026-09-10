import 'package:equatable/equatable.dart';

import '../../../../../shared/enums/bloc_status.dart';
import '../../../data/model/food_model.dart';

class FoodSearchState extends Equatable {
  const FoodSearchState({
    this.status = BlocStatus.initial,
    this.query = '',
    this.results = const [],
    this.isAdding = false,
    this.error,
  });

  final BlocStatus status;
  final String query;
  final List<FoodModel> results;
  final bool isAdding;
  final String? error;

  FoodSearchState copyWith({
    BlocStatus? status,
    String? query,
    List<FoodModel>? results,
    bool? isAdding,
    String? error,
  }) {
    return FoodSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      isAdding: isAdding ?? this.isAdding,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, query, results, isAdding, error];
}
