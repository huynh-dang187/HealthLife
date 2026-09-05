import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/health_news/presentation/cubit/health_news_state.dart';
import 'package:healthlife/src/features/health_news/presentation/widgets/news_skeleton.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:hive_ce/hive.dart';

import '../../data/repositories/rss_repository.dart';
import '../cubit/health_news_cubit.dart';
import '../widgets/news_list_item.dart';

class HealthNewsScreen extends StatelessWidget {
  const HealthNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: AppText.bold('Bảng tin sức khỏe', fontSize: 18),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) =>
            HealthNewsCubit(RssRepository(Hive.box('health_news')))..loadNews(),
        child: const _NewsBody(),
      ),
    );
  }
}

class _NewsBody extends StatelessWidget {
  const _NewsBody();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocBuilder<HealthNewsCubit, HealthNewsState>(
      builder: (context, state) {
        final cubit = context.read<HealthNewsCubit>();

        if (state.status == BlocStatus.loading && state.news.isEmpty) {
          return const NewsSkeleton();
        }

        if (state.status == BlocStatus.failure && state.news.isEmpty) {
          return _ErrorView(message: state.message ?? 'Không thể tải tin tức');
        }

        // success (hoặc có dữ liệu cache)
        return RefreshIndicator(
          onRefresh: cubit.refreshNews,
          color: isDark ? UIColors.darkTextPrimary : UIColors.pink,
          child: Column(
            children: [
              if (state.message != null)
                _OfflineBanner(message: state.message!),
              Expanded(
                child: state.news.isEmpty
                    ? const _EmptyView()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: state.news.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NewsListItem(article: state.news[index]),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      width: double.infinity,
      color: isDark ? UIColors.darkSurface : UIColors.pinkLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppText.regular(
        message,
        fontSize: 12,
        color: isDark ? UIColors.darkTextPrimary : UIColors.pink,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: isDark ? UIColors.darkTextSecondary : UIColors.textBody,
            ),
            16.gap,
            AppText.medium(
              message,
              fontSize: 14,
              color: isDark ? UIColors.darkTextSecondary : UIColors.textBody,
              textAlign: TextAlign.center,
            ),
            16.gap,
            AppButton.fill(
              onTap: () => context.read<HealthNewsCubit>().loadNews(),
              title: 'Thử lại',
              width: 120,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Center(
      child: AppText.regular(
        'Chưa có bài viết nào',
        fontSize: 14,
        color: isDark ? UIColors.darkTextSecondary : UIColors.textBody,
      ),
    );
  }
}
