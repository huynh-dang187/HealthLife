import 'package:healthlife/src/features/health_news/data/models/news_article_model.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class HealthNewsState {
  final BlocStatus status;
  final String? message;
  final List<NewsArticleModel> news;

  const HealthNewsState({
    this.status = BlocStatus.initial,
    this.message,
    this.news = const [],
  });

  HealthNewsState copyWith({
    BlocStatus? status,
    String? message,
    List<NewsArticleModel>? news,
  }) {
    return HealthNewsState(
      status: status ?? this.status,
      message: message ?? this.message,
      news: news ?? this.news,
    );
  }
}
