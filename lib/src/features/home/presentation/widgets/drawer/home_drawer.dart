import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/profile/profile_screen_cubit.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/profile/profile_screen_state.dart';
import 'package:healthlife/src/features/profile/presentation/widgets/languages/language_modal.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

import 'drawer_feature.dart';
import 'drawer_header.dart';
import 'drawer_section_label.dart';
import 'drawer_tile.dart';

/// Drawer điều hướng của màn hình Home: header tóm tắt, danh sách chức năng,
/// cài đặt ngôn ngữ và đăng xuất.
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText.semiBold(
          context.tr(LocaleKeys.profile_logout),
          fontSize: 18,
        ),
        content: AppText.regular(
          context.tr(LocaleKeys.profile_logout_confirm),
          fontSize: 14,
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AppText.medium(
              context.tr(LocaleKeys.profile_cancel),
              color: UIColors.textBody,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: AppText.medium(
              context.tr(LocaleKeys.profile_logout),
              color: UIColors.coral,
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<ProfileScreenCubit>().logout();
  }

  void _openFeature(BuildContext context, String route) {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    navigator.pop();
    router.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileScreenCubit>(
      create: (_) => ProfileScreenCubit(),
      child: BlocListener<ProfileScreenCubit, ProfileScreenState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == BlocStatus.success,
        listener: (context, _) {
          context.read<UserCubit>().clearUser();
          context.go(RouteNames.signIn);
        },
        child: Drawer(
          backgroundColor: UIColors.lightBackground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const HomeDrawerHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    children: [
                      DrawerSectionLabel(
                        context.tr(LocaleKeys.home_drawer_features),
                      ),
                      12.gap,
                      for (final feature in drawerFeatures) ...[
                        DrawerTile(
                          icon: feature.icon,
                          color: feature.color,
                          label: context.tr(feature.label),
                          onTap: () => _openFeature(context, feature.route),
                        ),
                        8.gap,
                      ],
                      const SizedBox(height: 8),
                      DrawerSectionLabel(
                        context.tr(LocaleKeys.profile_settings),
                      ),
                      12.gap,
                      DrawerTile(
                        icon: Icons.language_rounded,
                        color: UIColors.coral,
                        label: context.tr(LocaleKeys.profile_language),
                        onTap: () => showLanguageModal(context),
                        trailing: AppText.medium(
                          context.locale.languageCode == 'en'
                              ? 'English'
                              : 'Tiếng Việt',
                          fontSize: 13,
                          color: UIColors.textBody,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DrawerTile(
                          icon: Icons.logout_rounded,
                          color: UIColors.pink,
                          label: context.tr(LocaleKeys.profile_logout),
                          trailing: const SizedBox.shrink(),
                          onTap: () => _confirmLogout(context),
                        ),
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
