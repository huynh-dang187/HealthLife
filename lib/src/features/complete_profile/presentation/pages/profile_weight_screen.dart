import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/app_loading_screen.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_weight/profile_weight_cubit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_weight/profile_weight_state.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/weight/toggle_pill.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class ProfileWeightScreen extends StatelessWidget {
  const ProfileWeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileWeightCubit(ProfileRepository()),
      child: BlocBuilder<ProfileWeightCubit, ProfileWeightState>(
        builder: (context, state) {
          final cubit = context.read<ProfileWeightCubit>();
          return Scaffold(
            appBar: AppAppBar(
              title: "Nhập cân nặng của bạn",
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  24.gap,
                  AppText.bold("Vui lòng cho chúng tôi biết cân nặng của bạn"),
                  32.gap,
                  Row(
                    children: [
                      Expanded(
                        child: AppTF.common(
                          controller: cubit.weightController,
                          keyboardType: TextInputType.number,
                          onChanged: cubit.onWeightTextChanged,
                          rightWidget: AppText.medium(
                            state.unit == WeightUnit.kg ? "kg" : "lbs",
                            color: const Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                      12.gap,
                      TogglePill(
                        labels: const ['kg', 'lbs'],
                        selectedIndex: state.unit == WeightUnit.kg ? 0 : 1,
                        onChanged: (i) => cubit.setUnit(
                          i == 0 ? WeightUnit.kg : WeightUnit.lbs,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: AppButton.fill(
                      title: "Tiếp theo",
                      color: UIColors.pink,
                      onTap: () async {
                        AppLoadingScreen.show(context, message: "Đang lưu...");
                        final ok = await cubit.saveWeight();
                        if (!context.mounted) return;
                        if (ok) {
                          context.go(RouteNames.home);
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
