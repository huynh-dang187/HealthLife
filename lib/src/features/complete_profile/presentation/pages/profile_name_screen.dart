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

class ProfileName extends StatelessWidget {
  const ProfileName({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    return BlocProvider(
      create: (_) => ProfileNameCubit(ProfileRepository()),
      child: BlocBuilder<ProfileNameCubit, ProfileNameState>(
        builder: (context, state) {
          final cubit = context.read<ProfileNameCubit>();
          return Scaffold(
            appBar: AppAppBar(title: "Nhập tên của bạn", centerTitle: true),
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
                              "Bạn muốn HLife gọi bạn là gì?",
                            ),
                          ),
                          17.gap,
                          AppTF.common(
                            controller: nameController,
                            hintText: "Nhập tên của bạn",
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
                      title: "Tiếp theo",
                      enable: state.changeName.isNotEmpty,
                      onTap: () async {
                        AppLoadingScreen.show(
                          context,
                          message: "Đang lưu...",
                        );
                        final ok = await cubit.saveName(
                          state.changeName,
                        );
                        if (!context.mounted) return;
                        if (ok) {
                          context.go(RouteNames.profile_gender);
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
