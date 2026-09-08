part of 'medicine_search_cubit.dart';

class MedicineSearchState {
  final BlocStatus status;
  final List<Map<String, dynamic>> medicines;
  final List<String> relatedKeywords;
  final bool isSearching;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const MedicineSearchState({
    this.status = BlocStatus.initial,
    this.medicines = const [],
    this.relatedKeywords = const [],
    this.isSearching = false,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  MedicineSearchState copyWith({
    BlocStatus? status,
    List<Map<String, dynamic>>? medicines,
    List<String>? relatedKeywords,
    bool? isSearching,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return MedicineSearchState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      relatedKeywords: relatedKeywords ?? this.relatedKeywords,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}