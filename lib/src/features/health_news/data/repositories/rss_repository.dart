import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_revised/domain/rss_feed.dart';
import 'package:webfeed_revised/domain/rss_item.dart';

import '../models/news_article_model.dart';

class RssRepository {
  static const _url = 'https://suckhoedoisong.vn/suc-khoe-tv.rss';

  final Box _cacheBox;

  RssRepository(this._cacheBox);

  /// Lấy tin tức sức khỏe từ RSS
  Future<List<NewsArticleModel>> fetchHealthNews() async {
    final res = await http.get(Uri.parse(_url));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final feed = RssFeed.parse(res.body);

    return (feed.items ?? []).map(_toModel).toList();
  }

  /// Lấy danh sách tin tức đã cache
  Future<List<NewsArticleModel>> getCached() async {
    final cachedData = _cacheBox.get('health_news');

    if (cachedData == null) {
      return [];
    }

    final List<dynamic> data = List<dynamic>.from(cachedData);

    return data.map((item) {
      return NewsArticleModel.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  /// Lưu danh sách tin tức vào cache
  Future<void> saveCache(List<NewsArticleModel> news) async {
    final data = news.map((item) => item.toJson()).toList();

    await _cacheBox.put('health_news', data);
  }

  /// Chuyển RSS Item thành NewsArticleModel
  NewsArticleModel _toModel(RssItem item) {
    return NewsArticleModel(
      title: item.title ?? '',
      description: item.description ?? '',
      link: item.link ?? '',
      pubDate: item.pubDate ?? DateTime.now(),
      imageUrl: item.enclosure?.url,
    );
  }
}
