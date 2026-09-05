import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/enums/bloc_status.dart';

part 'medicine_search_state.dart';

class MedicineSearchCubit extends Cubit<MedicineSearchState> {
  MedicineSearchCubit() : super(const MedicineSearchState());

  int _page = 0;
  final int _pageSize = 10;
  String _currentQuery = '';

  // Lấy danh sách thuốc mặc định
  Future<void> fetchInitialMedicines() async {
    emit(state.copyWith(
      status: BlocStatus.loading,
      isSearching: false,
      hasMore: true,
      relatedKeywords: [],
    ));
    _page = 0;
    _currentQuery = '';

    try {
      final response = await Supabase.instance.client
          .rpc('get_random_otc_medicines', params: {'limit_count': 6});

      emit(state.copyWith(
        status: BlocStatus.success,
        medicines: List<Map<String, dynamic>>.from(response),
      ));
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, errorMessage: e.toString()));
    }
  }

  // Tìm kiếm thuốc
  Future<void> searchMedicine(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      fetchInitialMedicines();
      return;
    }

    _currentQuery = cleanQuery;
    _page = 0;
    emit(state.copyWith(status: BlocStatus.loading, isSearching: true, hasMore: true, medicines: []));

    try {
      final response = await Supabase.instance.client
          .from('medicines')
          .select()
          .or('name.ilike.%$cleanQuery%,active_ingredient.ilike.%$cleanQuery%,category.ilike.%$cleanQuery%')
          .range(0, _pageSize - 1);

      final results = List<Map<String, dynamic>>.from(response);

      // Trích xuất keyword
      final Set<String> extractedKeywords = {};
      for (var item in results) {
        final ingredient = item['active_ingredient']?.toString().trim();
        final category = item['category']?.toString().trim();

        if (ingredient != null && ingredient.isNotEmpty && !ingredient.toLowerCase().contains(cleanQuery.toLowerCase())) {
          extractedKeywords.add(ingredient);
        }
        if (category != null && category.isNotEmpty && !category.toLowerCase().contains(cleanQuery.toLowerCase())) {
          extractedKeywords.add(category);
        }
      }

      emit(state.copyWith(
        status: BlocStatus.success,
        medicines: results,
        relatedKeywords: extractedKeywords.take(4).toList(),
        hasMore: results.length == _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failure, errorMessage: e.toString()));
    }
  }

  // Tải thêm (Load More)
  Future<void> loadMoreMedicines() async {
    if (_currentQuery.isEmpty || !state.hasMore || state.isLoadingMore || state.status == BlocStatus.loading) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = _page + 1;
    final from = nextPage * _pageSize;
    final to = from + _pageSize - 1;

    try {
      final response = await Supabase.instance.client
          .from('medicines')
          .select()
          .or('name.ilike.%$_currentQuery%,active_ingredient.ilike.%$_currentQuery%,category.ilike.%$_currentQuery%')
          .range(from, to);

      final newResults = List<Map<String, dynamic>>.from(response);
      final updatedList = List<Map<String, dynamic>>.from(state.medicines)..addAll(newResults);

      _page = nextPage;
      emit(state.copyWith(
        medicines: updatedList,
        isLoadingMore: false,
        hasMore: newResults.length == _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void clearSearch() {
    fetchInitialMedicines();
  }
}
