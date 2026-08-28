import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/app_loading_screen.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_date/profile_date_cubit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_date/profile_date_state.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/date/box_date.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class ProfileDate extends StatelessWidget {
  const ProfileDate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileDateCubit(ProfileRepository()),
      child: BlocBuilder<ProfileDateCubit, ProfileDateState>(
        builder: (context, state) {
          final cubit = context.read<ProfileDateCubit>();
          return Scaffold(
            appBar: AppAppBar(
              title: "Nhập ngày sinh",
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  24.gap,
                  AppText.bold("Vui lòng cho chúng tôi biết ngày sinh của bạn"),
                  24.gap,
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            DateFieldItem(
                              label: "Ngày",
                              controller: cubit.dayController,
                              keyboardType: TextInputType.number,
                              maxNum: 2,
                            ),
                            17.gap,
                            DateFieldItem(
                              label: "Tháng",
                              controller: cubit.monthController,
                              keyboardType: TextInputType.number,
                              maxNum: 2,
                            ),
                            17.gap,
                            DateFieldItem(
                              label: "Năm",
                              controller: cubit.yearController,
                              keyboardType: TextInputType.number,
                              maxNum: 4,
                              hintText: "2005",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: context.bottomPadding),
                    child: AppButton.fill(
                      title: "Tiếp theo",
                      onTap: () async {
                        AppLoadingScreen.show(context, message: "Đang lưu...");
                        final ok = await cubit.saveDate();
                        if (!context.mounted) return;
                        if (ok) {
                          context.go(RouteNames.profile_height);
                        } else {
                          if (context.canPop()) context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Lưu thất bại, thử lại"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
