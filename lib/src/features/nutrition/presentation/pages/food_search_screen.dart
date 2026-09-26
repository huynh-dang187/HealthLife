import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/no_data.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import '../../data/datasources/nutrition_remote_data_source.dart';
import '../../data/model/food_model.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../cubit/foodSearch/food_search_cubit.dart';
import '../cubit/foodSearch/food_search_state.dart';
import '../widgets/add_food_amount_sheet.dart';

class FoodSearchScreen extends StatelessWidget {
  const FoodSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodSearchCubit(
        NutritionRepository(NutritionRemoteDataSource()),
      ),
      child: const _FoodSearchScreenBody(),
    );
  }
}

class _FoodSearchScreenBody extends StatefulWidget {
  const _FoodSearchScreenBody();

  @override
  State<_FoodSearchScreenBody> createState() => _FoodSearchScreenBodyState();
}

class _FoodSearchScreenBodyState extends State<_FoodSearchScreenBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectFood(FoodModel food) async {
    final cubit = context.read<FoodSearchCubit>();
    final added = await showAddFoodAmountSheet(
      context,
      food: food,
      onAdd: (grams) => cubit.addToLog(food, grams),
    );
    if (added && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      appBar: AppAppBar(
        title: context.tr(LocaleKeys.nutrition_search_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: AppTF.common(
                controller: _searchController,
                autofocus: true,
                hintText: context.tr(LocaleKeys.nutrition_search_hint),
                bgColor: UIColors.lightGray,
                borderCicular: 14,
                leftWidget: Assets.svg.iconSearch.svg(
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    UIColors.textBody,
                    BlendMode.srcIn,
                  ),
                ),
                onChanged: (value) =>
                    context.read<FoodSearchCubit>().onQueryChanged(value),
              ),
            ),
            Expanded(
              child: BlocBuilder<FoodSearchCubit, FoodSearchState>(
                builder: (context, state) {
                  if (state.query.trim().isEmpty) {
                    return Center(
                      child: AppText.italic(
                        context.tr(LocaleKeys.nutrition_search_prompt),
                      ),
                    );
                  }
                  if (state.status == BlocStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: UIColors.pink),
                    );
                  }
                  if (state.status == BlocStatus.failure) {
                    return Center(
                      child: NoData(
                        title: context.tr(LocaleKeys.nutrition_search_failed),
                      ),
                    );
                  }
                  if (state.results.isEmpty) {
                    return Center(
                      child: NoData(
                        title: context.tr(LocaleKeys.nutrition_search_empty),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: state.results.length,
                    separatorBuilder: (context, index) => 10.gap,
                    itemBuilder: (context, index) => _FoodTile(
                      food: state.results[index],
                      onTap: _selectFood,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food, required this.onTap});

  final FoodModel food;
  final ValueChanged<FoodModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UIColors.lightCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(food),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: UIColors.lightGray,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 19,
                  color: UIColors.pink,
                ),
              ),
              12.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.medium(
                      food.name,
                      fontSize: 13.5,
                      maxLines: 1,
                      color: UIColors.text,
                    ),
                    4.gap,
                    AppText.regular(
                      '${food.group} • ${food.calo.round()} kcal/'
                      '${food.servingG.round()}g',
                      fontSize: 11.5,
                      color: UIColors.textBody,
                    ),
                  ],
                ),
              ),
              8.gap,
              Assets.svg.icChevronRight.svg(
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  UIColors.textBody,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
