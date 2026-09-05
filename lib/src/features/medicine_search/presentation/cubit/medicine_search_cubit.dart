import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/medicine_model.dart';
import '../../data/repositories/medicine_repository.dart';

part 'medicine_search_state.dart';

class MedicineSearchCubit extends Cubit<MedicineSearchState> {
  final MedicineRepository _repository;

  MedicineSearchCubit(this._repository) : super(const MedicineSearchState());

  void searchMedicine(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(status: MedicineSearchStatus.initial, medicines: []));
      return;
    }

    emit(state.copyWith(status: MedicineSearchStatus.loading));

    try {
      final results = await _repository.searchMedicines(query);
      emit(state.copyWith(status: MedicineSearchStatus.success, medicines: results));
    } catch (e) {
      emit(state.copyWith(
        status: MedicineSearchStatus.failure,
        errorMessage: 'Lỗi tải dữ liệu: $e',
      ));
    }
  }
}
