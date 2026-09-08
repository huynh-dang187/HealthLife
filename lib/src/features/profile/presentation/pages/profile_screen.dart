import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/daily_tips/data/repositories/daily_tip_repository.dart';
import 'package:healthlife/src/features/daily_tips/presentation/cubit/daily_tip_cubit.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/profile/profile_screen_cubit.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/profile/profile_screen_state.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/changeProfile/change_profile_bottom_sheet.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/languages/language_modal.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile/profile_header.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile/profile_menu_item.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile/profile_menu_section.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile/profile_tip_card.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileScreenCubit>(
      create: (_) => ProfileScreenCubit(),
      child: BlocListener<ProfileScreenCubit, ProfileScreenState>(
        listener: (context, state) {
          if (state.status == BlocStatus.success) {
            context.read<UserCubit>().clearUser();
            context.go(RouteNames.signIn);
          }
        },
        child: const _ProfileBody(),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText.semiBold('Đăng xuất', fontSize: 18),
        content: AppText.regular(
          'Bạn có chắc muốn đăng xuất khỏi HLife?',
          fontSize: 14,
          maxLines: 2,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.pop(false),
                  child: AppText.medium('Hủy', color: UIColors.textBody),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppButton.fill(
                    onTap: () => context.pop(true),
                    titleWidget: AppText.medium(
                      'Đăng xuất',
                      color: UIColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;
    await context.read<ProfileScreenCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state.user;
    final status = context.watch<ProfileScreenCubit>().state.status;

    return Scaffold(
      backgroundColor: UIColors.lightBackground,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: context.bottomPadding + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(user: user),
              24.gap,
              BlocProvider(
                create: (_) => DailyTipCubit(DailyTipRepository())..loadTip(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ProfileTipCard(),
                ),
              ),
              24.gap,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ProfileMenuSection(
                  title: 'Cài đặt',
                  items: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      label: 'Thông tin cơ bản',
                      onTap: () => showChangeProfileSheet(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.language_outlined,
                      label: 'Ngôn ngữ',
                      onTap: () => showLanguageModal(context),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText.medium(
                            context.locale.languageCode == 'en'
                                ? 'English'
                                : 'Tiếng Việt',
                            fontSize: 13,
                            color: UIColors.textBody,
                          ),
                          6.gap,
                          const Icon(
                            Icons.chevron_right,
                            color: UIColors.textBody,
                          ),
                        ],
                      ),
                    ),
                    const ProfileMenuItem(
                      icon: Icons.notifications_none,
                      label: 'Thông báo',
                      trailing: _NotificationSwitch(),
                    ),
                    const ProfileMenuItem(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Nhà tài trợ',
                    ),
                  ],
                ),
              ),
              24.gap,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppButton.fill(
                  title: 'Đăng xuất',
                  color: UIColors.pink,
                  height: 40,
                  enable: status != BlocStatus.loading,
                  onTap: () => _confirmLogout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatefulWidget {
  const _NotificationSwitch();

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _enabled,
      activeThumbColor: UIColors.pink,
      onChanged: (value) => setState(() => _enabled = value),
    );
  }
}
