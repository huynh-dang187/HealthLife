import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
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
              title: context.tr(LocaleKeys.complete_profile_weight_title),
              centerTitle: true,
              onBack: () {
                context.pop();
              },
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  24.gap,
                  AppText.bold(
                    context.tr(LocaleKeys.complete_profile_weight_subtitle),
                  ),
                  32.gap,
                  Row(
                    children: [
                      Expanded(
                        child: AppTF.common(
                          controller: cubit.weightController,
                          keyboardType: TextInputType.number,
                          onChanged: cubit.onWeightTextChanged,
                          rightWidget: AppText.medium(
                            context.tr(
                              state.unit == WeightUnit.kg
                                  ? LocaleKeys.complete_profile_weight_unit_kg
                                  : LocaleKeys.complete_profile_weight_unit_lbs,
                            ),
                            color: const Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                      12.gap,
                      TogglePill(
                        labels: [
                          context.tr(LocaleKeys.complete_profile_weight_unit_kg),
                          context.tr(LocaleKeys.complete_profile_weight_unit_lbs),
                        ],
                        selectedIndex: state.unit == WeightUnit.kg ? 0 : 1,
                        onChanged: (i) => cubit.setUnit(
                          i == 0 ? WeightUnit.kg : WeightUnit.lbs,
                        ),
                      ),
                    ],
                  ),
                  if (state.weightError) ...[
                    16.gap,
                    AppText.semiBold(
                      context.tr(LocaleKeys.complete_profile_weight_error),
                      color: UIColors.coral,
                      maxLines: 3,
                    ),
                  ],
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: AppButton.fill(
                      title: context.tr(LocaleKeys.complete_profile_action_next),
                      enable: !state.weightError,
                      color: UIColors.coral,
                      onTap: () async {
                        AppLoadingScreen.show(
                          context,
                          message: context.tr(LocaleKeys.complete_profile_saving),
                        );
                        final ok = await cubit.saveWeight();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        if (ok) {
                          // Nạp lại user (name/gender/date/height/weight) sau khi
                          // hoàn tất profile để UI home/profile hiển thị đúng.
                          await context.read<UserCubit>().loadUser();
                          if (!context.mounted) return;
                          context.push(RouteNames.home);
                        } else {
                          if (context.canPop()) context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.tr(
                                  LocaleKeys.complete_profile_save_failed,
                                ),
                              ),
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
