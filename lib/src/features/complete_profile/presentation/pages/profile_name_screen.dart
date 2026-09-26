import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/app_bar.dart';
import 'package:healthlife/src/core/presentation/widgets/app_loading_screen.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_name/profile_name_cubit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/cubit/profile_name/profile_name_state.dart';
import 'package:healthlife/src/shared/router/route_names.dart';
import 'package:healthlife/generated/locale_keys.g.dart';

class ProfileName extends StatelessWidget {
  const ProfileName({super.key});

  @override
  Widget build(BuildContext context) {
    final prefill = FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    final nameController = TextEditingController(text: prefill);
    return BlocProvider(
      create: (_) => ProfileNameCubit(ProfileRepository())..onChangeName(prefill),
      child: BlocBuilder<ProfileNameCubit, ProfileNameState>(
        builder: (context, state) {
          final cubit = context.read<ProfileNameCubit>();
          return Scaffold(
            appBar: AppAppBar(
              title: context.tr(LocaleKeys.complete_profile_name_title),
              centerTitle: true,
              onBack: () {
                context.pop();
              },
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 24, bottom: 16),
                      child: Column(
                        children: [
                          Center(
                            child: AppText.bold(
                              context.tr(
                                LocaleKeys.complete_profile_name_question,
                              ),
                            ),
                          ),
                          17.gap,
                          AppTF.common(
                            controller: nameController,
                            hintText: context.tr(
                              LocaleKeys.complete_profile_name_hint,
                            ),
                            rightWidget: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  nameController.clear();
                                  cubit.onChangeName("");
                                },
                                child: Assets.svg.icClose.svg(width: 32),
                              ),
                            ),
                            onChanged: (text) => cubit.onChangeName(text),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: context.bottomPadding),
                    child: AppButton.fill(
                      title: context.tr(LocaleKeys.complete_profile_action_next),
                      onTap: () async {
                        AppLoadingScreen.show(
                          context,
                          message: context.tr(LocaleKeys.complete_profile_saving),
                        );
                        final ok = await cubit.saveName(state.changeName);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();

                        if (ok) {
                          context.push(RouteNames.profile_gender);
                        } else {
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
