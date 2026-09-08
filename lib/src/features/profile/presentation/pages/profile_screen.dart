import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/daily_tips/data/repositories/daily_tip_repository.dart';
import 'package:healthlife/src/features/daily_tips/presentation/cubit/daily_tip_cubit.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile_header.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile_menu_section.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/profile_tip_card.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText.semiBold('Đăng xuất', fontSize: 18),
        content: AppText.regular(
          'Bạn có chắc muốn đăng xuất khỏi HLife?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: AppText.medium('Hủy', color: UIColors.textBody),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: AppText.medium('Đăng xuất', color: UIColors.pink),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    if (!context.mounted) return;
    context.go(RouteNames.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state.user;

    return BlocProvider(
      create: (_) => DailyTipCubit(DailyTipRepository())..loadTip(),
      child: Scaffold(
        backgroundColor: UIColors.lightBackground,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: context.bottomPadding + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  user: user,
                  onLogout: () => _confirmLogout(context),
                ),
                24.gap,
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ProfileTipCard(),
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
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.language_outlined,
                        label: 'Ngôn ngữ',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.medium(
                              'Tiếng Việt',
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
              ],
            ),
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
      activeColor: UIColors.pink,
      onChanged: (value) => setState(() => _enabled = value),
    );
  }
}
