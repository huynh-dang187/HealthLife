import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/app_bar.dart';
import '../../../../core/presentation/widgets/text.dart';
import '../cubit/water_cubit.dart';
import '../cubit/water_state.dart';
import '../widgets/custom_water_dialog.dart';
import '../widgets/quick_add_water_section.dart';
import '../widgets/water_log_tile.dart';
import '../widgets/water_progress_card.dart';
import '../widgets/water_settings_dialog.dart';

class WaterReminderPage extends StatelessWidget {
  const WaterReminderPage({super.key});

  void _openSettingsDialog(BuildContext context, WaterState state) {
    final cubit = context.read<WaterCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => WaterSettingsDialog(
        settings: state.settings,
        onGoalUpdated: (newGoal) => cubit.updateDailyGoal(newGoal),
        onToggleReminder: (isEnabled) => cubit.toggleReminder(isEnabled),
        onScheduleUpdated: (startTime, endTime, interval) {
          cubit.updateReminderSchedule(
            startTime: startTime,
            endTime: endTime,
            intervalHours: interval,
          );
        },
      ),
    );
  }

  void _openCustomWaterDialog(BuildContext context) {
    final cubit = context.read<WaterCubit>();
    showDialog(
      context: context,
      builder: (dialogCtx) => CustomWaterDialog(
        onConfirm: (amount) => cubit.addWater(amount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WaterCubit()..loadInitialData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppAppBar(
          title: 'water_reminder_title'.tr(),
          centerTitle: true,
          bgColor: const Color(0xFFF7F9FC),
          rightBtns: [
            BlocBuilder<WaterCubit, WaterState>(
              builder: (context, state) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF0288D1),
                  ),
                  onPressed: () => _openSettingsDialog(context, state),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<WaterCubit, WaterState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: AppText.regular(
                    state.errorMessage!,
                    color: UIColors.white,
                  ),
                  backgroundColor: UIColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0288D1)),
              );
            }

            final cubit = context.read<WaterCubit>();

            return RefreshIndicator(
              onRefresh: () => cubit.loadInitialData(),
              color: const Color(0xFF0288D1),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thẻ tiến độ uống nước
                    WaterProgressCard(
                      currentIntake: state.currentIntake,
                      dailyGoal: state.dailyGoal,
                      progress: state.progressPercentage,
                      isGoalReached: state.isGoalReached,
                    ),
                    24.gap,

                    // Mục thêm nhanh
                    QuickAddWaterSection(
                      onAddWater: (amount) => cubit.addWater(amount),
                      onCustomTap: () => _openCustomWaterDialog(context),
                    ),
                    24.gap,

                    // Tiêu đề lịch sử
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.bold(
                          'water_reminder_today_history'.tr(),
                          fontSize: 16,
                          color: UIColors.text,
                        ),
                        AppText.medium(
                          'water_reminder_logs_count'.tr(
                            namedArgs: {'count': state.todayLogs.length.toString()},
                          ),
                          fontSize: 13,
                          color: UIColors.textBody,
                        ),
                      ],
                    ),
                    12.gap,

                    // Danh sách nhật ký uống nước
                    if (state.todayLogs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        decoration: BoxDecoration(
                          color: UIColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: UIColors.separate),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.water_drop_outlined,
                              size: 48,
                              color: Color(0xFFB0BEC5),
                            ),
                            12.gap,
                            AppText.medium(
                              'water_reminder_no_logs_today'.tr(),
                              color: UIColors.textBody,
                              fontSize: 14,
                            ),
                            4.gap,
                            AppText.regular(
                              'water_reminder_no_logs_hint'.tr(),
                              color: const Color(0xFFB0BEC5),
                              fontSize: 12,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.todayLogs.length,
                        itemBuilder: (context, index) {
                          final log = state.todayLogs[index];
                          return WaterLogTile(
                            log: log,
                            onDelete: () => cubit.deleteWaterLog(log.id),
                          );
                        },
                      ),
                    24.gap,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}