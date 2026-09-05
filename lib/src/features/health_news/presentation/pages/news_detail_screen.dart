import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/health_news/presentation/widgets/news_time.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../data/models/news_article_model.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.article});

  final NewsArticleModel article;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: AppText.bold('Chi tiết tin', fontSize: 18),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh lớn
            _ArticleImage(imageUrl: article.imageUrl),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ngày đăng
                  AppText.regular(
                    formatRelativeTime(article.pubDate),
                    fontSize: 12,
                    color: isDark
                        ? UIColors.darkTextSecondary
                        : UIColors.textBody,
                  ),
                  12.gap,
                  // Tiêu đề
                  AppText.bold(
                    article.title,
                    fontSize: 20,
                    maxLines: 4,
                    textOverflow: TextOverflow.ellipsis,
                    color: isDark ? UIColors.darkTextPrimary : UIColors.text,
                  ),
                  16.gap,
                  // Nội dung
                  article.description.trim().isEmpty
                      ? AppText.regular(
                          'Chưa có nội dung chi tiết cho bài viết này.',
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? UIColors.darkTextSecondary
                              : UIColors.textBody,
                        )
                      : AppText.regular(
                          article.description,
                          fontSize: 14,
                          height: 1.6,
                          textOverflow: TextOverflow.visible,
                          color: isDark
                              ? UIColors.darkTextPrimary
                              : UIColors.text,
                        ),
                  24.gap,
                  // Nút mở bài gốc
                  AppButton.fill(
                    onTap: () => context.push(
                      RouteNames.news_webview,
                      extra: article.link,
                    ),
                    title: 'Mở bài gốc',
                    height: 48,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final placeholderColor = isDark ? UIColors.darkSurface : UIColors.pinkLight;

    Widget placeholder = Container(
      width: double.infinity,
      height: 220,
      color: placeholderColor,
      alignment: Alignment.center,
      child: Icon(
        Icons.newspaper_outlined,
        size: 56,
        color: isDark ? UIColors.darkTextSecondary : UIColors.pink,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}
