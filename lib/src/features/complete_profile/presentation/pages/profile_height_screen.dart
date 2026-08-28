import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/app_loading_screen.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_height/profile_height_cubit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_height/profile_height_state.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/height/height_rule.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/height/unit_toggle.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class ProfileHeight extends StatelessWidget {
  const ProfileHeight({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileHeightCubit(ProfileRepository()),
      child: BlocBuilder<ProfileHeightCubit, ProfileHeightState>(
        builder: (context, state) {
          final cubit = context.read<ProfileHeightCubit>();
          return Scaffold(
            appBar: AppAppBar(
              title: "Chiều cao của bạn",
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  24.gap,
                  AppText.bold(
                    "Vui lòng cho chúng tôi biết chiều cao của bạn",
                  ),
                  32.gap,
                  Row(
                    children: [
                      Expanded(
                        child: AppTF.common(
                          controller: cubit.heightController,
                          keyboardType: TextInputType.number,
                          onChanged: cubit.onHeightTextChanged,
                          rightWidget: AppText.medium(
                            state.unit == HeightUnit.cm ? "cm" : "ft",
                            color: const Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                      12.gap,
                      UnitToggle(
                        value: state.unit,
                        onChanged: cubit.setUnit,
                      ),
                    ],
                  ),
                  40.gap,
                  HeightRuler(
                    valueCm: state.heightCm,
                    onChanged: cubit.selectHeight,
                    unit: state.unit, // ← New
                    minCm: cubit.minCm, // ← New
                    maxCm: cubit.maxCm,
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: context.bottomPadding),
                    child: AppButton.fill(
                      title: "Tiếp theo",
                      color: UIColors.pink,
                      onTap: () async {
                        AppLoadingScreen.show(context, message: "Đang lưu...");
                        final ok = await cubit.saveHeight();
                        if (!context.mounted) return;
                        if (ok) {
                          context.go(RouteNames.profile_weight);
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
