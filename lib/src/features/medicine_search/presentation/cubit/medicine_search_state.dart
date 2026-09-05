part of 'medicine_search_cubit.dart';

enum MedicineSearchStatus { initial, loading, success, failure }

class MedicineSearchState {
  final MedicineSearchStatus status;
  final List<MedicineModel> medicines;
  final String? errorMessage;

  const MedicineSearchState({
    this.status = MedicineSearchStatus.initial,
    this.medicines = const [],
    this.errorMessage,
  });

  MedicineSearchState copyWith({
    MedicineSearchStatus? status,
    List<MedicineModel>? medicines,
    String? errorMessage,
  }) {
    return MedicineSearchState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}