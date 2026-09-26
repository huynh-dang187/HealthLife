import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/health_news/presentation/cubit/health_news_cubit.dart';
import 'package:healthlife/src/features/health_news/presentation/cubit/health_news_state.dart';
import 'package:healthlife/src/features/health_news/presentation/widgets/news_list_item.dart';
import 'package:healthlife/src/features/health_news/presentation/widgets/news_skeleton.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 12, top: 24),
          child: Row(
            children: [
              Expanded(
                child: AppText.semiBold(
                  context.tr(LocaleKeys.home_news_section_title),
                  fontSize: 16,
                ),
              ),
              AppButton.widget(
                onTap: () => context.push(RouteNames.health_news),
                child: Row(
                  children: [
                    AppText.medium(
                      context.tr(LocaleKeys.home_news_view_all),
                      fontSize: 12,
                      color: UIColors.pink,
                    ),
                    2.gap,
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: UIColors.pink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        12.gap,
        BlocBuilder<HealthNewsCubit, HealthNewsState>(
          builder: (context, state) {
            if (state.status == BlocStatus.loading && state.news.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: NewsSkeleton(itemCount: 3),
                    ),
                  ],
                ),
              );
            }

            if (state.status == BlocStatus.failure && state.news.isEmpty) {
              return const SizedBox.shrink();
            }

            final items = state.news.take(10).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) 12.gap,
                    NewsListItem(article: items[i]),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
