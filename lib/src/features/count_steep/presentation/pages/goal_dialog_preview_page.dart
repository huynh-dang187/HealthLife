import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/count_steep/data/repositories/activity_repository.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_cubit.dart';

import '../widgets/set_goal_dialog.dart';

class GoalDialogPreviewPage extends StatelessWidget {
  const GoalDialogPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityDashboardCubit(ActivityRepository()),
      child: const _PreviewBody(),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppAppBar(title: 'Test dialog đặt mục tiêu'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.regular(
                    'Bấm nút bên dưới để mở dialog',
                    fontSize: 13,
                    color: UIColors.textBody,
                  ),
                  16.gap,
                  AppButton.fill(
                    title: 'Mở dialog',
                    width: 220,
                    height: 46,
                    color: UIColors.pink,
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => showSetGoalDialog(
                      context,
                      cubit: context.read<ActivityDashboardCubit>(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
