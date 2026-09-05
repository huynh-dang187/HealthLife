import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/health_news/presentation/widgets/news_time.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import '../../data/models/news_article_model.dart';

class NewsListItem extends StatelessWidget {
  const NewsListItem({super.key, required this.article});

  final NewsArticleModel article;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => context.push(
        RouteNames.news_detail,
        extra: article,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? UIColors.darkCard : UIColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: UIColors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(imageUrl: article.imageUrl),
            12.gap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bold(
                    article.title,
                    fontSize: 14,
                    color: isDark ? UIColors.darkTextPrimary : UIColors.text,
                    maxLines: 2,
                  ),
                  6.gap,
                  AppText.regular(
                    formatRelativeTime(article.pubDate),
                    fontSize: 11,
                    color: isDark
                        ? UIColors.darkTextSecondary
                        : UIColors.textBody,
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final placeholderColor = isDark ? UIColors.darkSurface : UIColors.pinkLight;

    Widget placeholder = Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.newspaper_outlined,
        size: 28,
        color: isDark ? UIColors.darkTextSecondary : UIColors.pink,
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}
