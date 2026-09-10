import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/no_data.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/router/route_names.dart';
import 'package:intl/intl.dart';

import '../../data/model/meal_log_model.dart';
import '../cubit/nutrion/nutrition_dashboard_cubit.dart';
import '../cubit/nutrion/nutrition_dashboard_state.dart';
import '../widgets/add_food_method_sheet.dart';
import '../widgets/calories_progress_ring.dart';
import '../widgets/macro_card.dart';
import '../widgets/meal_log_tile.dart';
import '../widgets/period_selector.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({super.key});

  @override
  State<NutritionDashboardScreen> createState() =>
      _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionDashboardCubit>().load();
    });
  }

  Future<void> _onAddFood() async {
    final method = await showAddFoodMethodSheet(context);
    if (method != AddFoodMethod.search || !mounted) return;

    final added = await context.push<bool>(RouteNames.nutrition_food_search);
    if (added == true && mounted) {
      await context.read<NutritionDashboardCubit>().reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm vào nhật ký')),
      );
    }
  }

  Future<void> _showLogDetail(MealLogModel log) async {
    final delete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: UIColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LogDetailSheet(log: log),
    );
    if (delete == true && mounted) {
      await context.read<NutritionDashboardCubit>().deleteLog(log);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xoá bữa ăn khỏi nhật ký')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      appBar: AppAppBar(
        title: 'Dinh dưỡng',
        centerTitle: true,
        leftBtn: const SizedBox(width: 16),
      ),
      body: BlocBuilder<NutritionDashboardCubit, NutritionDashboardState>(
        buildWhen: (prev, current) =>
            prev.status != current.status ||
            prev.period != current.period ||
            prev.consumed != current.consumed ||
            prev.logs != current.logs ||
            prev.targets != current.targets,
        builder: (context, state) {
          if (state.status == BlocStatus.loading && state.logs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: UIColors.pink),
            );
          }
          if (state.status == BlocStatus.failure && state.logs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.regular(
                      'Không tải được dữ liệu',
                      color: UIColors.textBody,
                    ),
                    if (state.error != null) ...[
                      8.gap,
                      SelectableText(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: UIColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    12.gap,
                    AppButton.outline(
                      title: 'Thử lại',
                      onTap: () =>
                          context.read<NutritionDashboardCubit>().load(),
                    ),
                  ],
                ),
              ),
            );
          }

          final cubit = context.read<NutritionDashboardCubit>();
          final targets = state.scaledTargets;

          return RefreshIndicator(
            onRefresh: cubit.reload,
            color: UIColors.pink,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                PeriodSelector(
                  selected: state.period,
                  onChanged: (p) => cubit.changePeriod(p),
                ),
                16.gap,
                _SummaryCard(
                  consumedCalo: state.consumed.calo,
                  progress: state.consumedCaloPercent / 100,
                  goalCalo: targets.calo,
                  percent: state.consumedCaloPercent,
                ),
                16.gap,
                Row(
                  children: [
                    Expanded(
                      child: MacroCard(
                        icon: Icons.egg_alt_outlined,
                        color: UIColors.pink,
                        bg: UIColors.pinkLight,
                        label: 'Chất đạm',
                        value:
                            '${state.consumed.protein.round()}/${targets.protein.round()}g',
                        percent: state.consumedProteinPercent,
                      ),
                    ),
                    10.gap,
                    Expanded(
                      child: MacroCard(
                        icon: Icons.grain,
                        color: UIColors.vibrantBlue,
                        bg: const Color(0xFFEDF0FF),
                        label: 'Carbs',
                        value:
                            '${state.consumed.carb.round()}/${targets.carb.round()}g',
                        percent: state.consumedCarbPercent,
                      ),
                    ),
                    10.gap,
                    Expanded(
                      child: MacroCard(
                        icon: Icons.water_drop_outlined,
                        color: const Color(0xFFE9A13B),
                        bg: const Color(0xFFFFF3E0),
                        label: 'Chất béo',
                        value:
                            '${state.consumed.fat.round()}/${targets.fat.round()}g',
                        percent: state.consumedFatPercent,
                      ),
                    ),
                  ],
                ),
                12.gap,
                _AllValuesCard(state: state),
                20.gap,
                Row(
                  children: [
                    AppText.bold('Nhật ký ăn', fontSize: 16),
                    const Spacer(),
                    GestureDetector(
                      onTap: _onAddFood,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: UIColors.pink,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              size: 16,
                              color: UIColors.white,
                            ),
                            6.gap,
                            AppText.semiBold(
                              'Thêm thực phẩm',
                              fontSize: 13,
                              color: UIColors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                12.gap,
                if (state.logs.isEmpty)
                  NoData(
                    title: 'Chưa có bữa ăn nào trong khoảng thời gian này',
                  )
                else
                  ...state.logs.map(
                    (log) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MealLogTile(
                        log: log,
                        onTap: () => _showLogDetail(log),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.consumedCalo,
    required this.progress,
    required this.goalCalo,
    required this.percent,
  });

  final double consumedCalo;
  final double progress;
  final double goalCalo;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CaloriesProgressRing(
            calories: consumedCalo,
            progress: progress,
          ),
          16.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Mục tiêu',
                        value: '${goalCalo.round()}',
                        unit: 'kcal',
                      ),
                    ),
                    8.gap,
                    Expanded(
                      child: _MiniStat(
                        label: 'Đã nạp',
                        value: '${percent.round()}',
                        unit: '%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.regular(label, fontSize: 10.5, color: UIColors.textBody),
          4.gap,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText.semiBold(value, fontSize: 17),
                3.gap,
                AppText.regular(
                  unit,
                  fontSize: 11,
                  color: UIColors.textBody,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllValuesCard extends StatelessWidget {
  const _AllValuesCard({required this.state});

  final NutritionDashboardState state;

  @override
  Widget build(BuildContext context) {
    final targets = state.scaledTargets;
    return Container(
      decoration: BoxDecoration(
        color: UIColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: UIColors.pink,
        collapsedIconColor: UIColors.textBody,
        title: AppText.medium(
          'Xem tất cả các giá trị dinh dưỡng',
          fontSize: 13,
        ),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ValueChip(
                label: 'Calo',
                value:
                    '${state.consumed.calo.round()}/${targets.calo.round()} kcal',
              ),
              _ValueChip(
                label: 'Chất đạm',
                value:
                    '${state.consumed.protein.round()}/${targets.protein.round()}g',
              ),
              _ValueChip(
                label: 'Carbs',
                value:
                    '${state.consumed.carb.round()}/${targets.carb.round()}g',
              ),
              _ValueChip(
                label: 'Chất béo',
                value: '${state.consumed.fat.round()}/${targets.fat.round()}g',
              ),
              _ValueChip(
                label: 'Chất xơ',
                value:
                    '${state.consumed.fiber.round()}/${targets.fiber.round()}g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.regular(label, fontSize: 11, color: UIColors.textBody),
          6.gap,
          AppText.semiBold(value, fontSize: 11, color: UIColors.text),
        ],
      ),
    );
  }
}

class _LogDetailSheet extends StatelessWidget {
  const _LogDetailSheet({required this.log});

  final MealLogModel log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: UIColors.separate,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          20.gap,
          AppText.bold('Chi tiết bữa ăn', fontSize: 16),
          16.gap,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UIColors.lightGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(log.foodName, fontSize: 14),
                4.gap,
                AppText.regular(
                  '${log.calo.round()} kcal • '
                  '${DateFormat('HH:mm').format(log.mealTime)}'
                  ' • ${log.grams.round()} g',
                  fontSize: 12,
                  color: UIColors.textBody,
                ),
                12.gap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ValueCell('Đạm', '${log.protein.round()}g'),
                    _ValueCell('Carbs', '${log.carb.round()}g'),
                    _ValueCell('Chất béo', '${log.fat.round()}g'),
                    _ValueCell('Chất xơ', '${log.fiber.round()}g'),
                  ],
                ),
              ],
            ),
          ),
          20.gap,
          AppButton.outline(
            title: 'Xoá khỏi nhật ký',
            height: 48,
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.regular(label, fontSize: 11, color: UIColors.textBody),
        4.gap,
        AppText.semiBold(value, fontSize: 12),
      ],
    );
  }
}
