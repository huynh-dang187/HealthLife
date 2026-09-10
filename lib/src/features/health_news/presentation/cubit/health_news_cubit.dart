import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/features/health_news/data/models/news_article_model.dart';
import 'package:healthlife/src/features/health_news/data/repositories/rss_repository.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import 'health_news_state.dart';

class HealthNewsCubit extends Cubit<HealthNewsState> {
  final RssRepository _repo;

  HealthNewsCubit(this._repo) : super(const HealthNewsState());

  Future<void> loadNews({
    bool showLoading = true,
  }) async {
    List<NewsArticleModel> cached = [];

    // 1. Lấy dữ liệu từ cache trước
    try {
      cached = await _repo.getCached();

      if (cached.isNotEmpty) {
        emit(
          state.copyWith(
            status: BlocStatus.success,
            news: cached,
            message: null,
          ),
        );
      }
    } catch (_) {
      // Nếu cache lỗi thì vẫn tiếp tục gọi API
    }

    // 2. Nếu không có cache thì hiển thị loading
    if (showLoading && cached.isEmpty) {
      emit(
        state.copyWith(
          status: BlocStatus.loading,
          message: null,
        ),
      );
    }

    // 3. Fetch dữ liệu mới từ RSS
    try {
      final fresh = await _repo.fetchHealthNews();

      // Lưu cache
      await _repo.saveCache(fresh);

      // Cập nhật UI bằng dữ liệu mới
      emit(
        state.copyWith(
          status: BlocStatus.success,
          news: fresh,
          message: null,
        ),
      );
    } catch (e) {
      // 4. Nếu không có cache → báo lỗi
      if (cached.isEmpty) {
        emit(
          state.copyWith(
            status: BlocStatus.failure,
            message: e.toString(),
          ),
        );
      } else {
        // Có cache → vẫn giữ dữ liệu cũ
        emit(
          state.copyWith(
            status: BlocStatus.success,
            news: cached,
            message: 'Không thể tải tin mới. Đang hiển thị dữ liệu đã lưu.',
          ),
        );
      }
    }
  }

  /// Refresh tin tức
  Future<void> refreshNews() async {
    await loadNews(showLoading: false);
  }
}
