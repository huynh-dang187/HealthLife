class NewsArticleModel {
  final String title;
  final String description;
  final String link;
  final DateTime pubDate;
  final String? imageUrl;

  const NewsArticleModel({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
    this.imageUrl,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      link: json['link'] as String? ?? '',
      pubDate:
          DateTime.tryParse(json['pubDate'] as String? ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': link,
      'pubDate': pubDate.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
