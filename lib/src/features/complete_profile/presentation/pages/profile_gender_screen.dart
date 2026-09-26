import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/app_loading_screen.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_gender/profile_gender_cubit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_gender/profile_gender_state.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/gender/box_gender.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class ProfileGender extends StatelessWidget {
  const ProfileGender({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileGenderCubit(ProfileRepository()),
      child: BlocBuilder<ProfileGenderCubit, ProfileGenderState>(
        builder: (context, state) {
          final cubit = context.read<ProfileGenderCubit>();
          return Scaffold(
            appBar: AppAppBar(
              title: context.tr(LocaleKeys.complete_profile_gender_title),
              centerTitle: true,
              onBack: () {
                context.pop();
              },
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    24.gap,
                    AppText.bold(
                      context.tr(LocaleKeys.complete_profile_gender_subtitle),
                    ),
                    20.gap,
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GenderOption(
                                image: Assets.png.icFemale.image(
                                  width: 100,
                                  height: 100,
                                ),
                                isSelected:
                                    state.selectedGender == Gender.female,
                                onTap: () => cubit.selectGender(Gender.female),
                                gender: Gender.female,
                              ),
                              16.gap,
                              GenderOption(
                                image: Assets.png.icMale.image(
                                  width: 100,
                                  height: 100,
                                ),
                                isSelected: state.selectedGender == Gender.male,
                                onTap: () => cubit.selectGender(Gender.male),
                                gender: Gender.male,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: context.bottomPadding),
                      child: AppButton.fill(
                        title: context.tr(
                          LocaleKeys.complete_profile_action_next,
                        ),
                        enable: state.selectedGender != null,
                        onTap: () async {
                          AppLoadingScreen.show(
                            context,
                            message: context.tr(
                              LocaleKeys.complete_profile_saving,
                            ),
                          );
                          final ok = await context
                              .read<ProfileGenderCubit>()
                              .saveGender(state.selectedGender!);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          if (ok) {
                            context.push(
                              RouteNames.profile_date,
                            );
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
            ),
          );
        },
      ),
    );
  }
}
