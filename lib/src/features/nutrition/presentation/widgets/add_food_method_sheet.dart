import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import 'tab_aware_sheet.dart';

enum AddFoodMethod {
  /// Tìm kiếm trong cơ sở dữ liệu — active.
  search,

  /// Sử dụng giọng nói — disabled (chưa code).
  voice,

  /// Scan thức ăn với AI — disabled (nhóm khác phụ trách).
  scan,
}

/// Hiện bottom sheet chọn cách thêm thực phẩm. Trả về method đã chọn
/// (hoặc null nếu huỷ / chọn mục disabled thì không pop).
Future<AddFoodMethod?> showAddFoodMethodSheet(BuildContext context) {
  return showModalBottomSheet<AddFoodMethod>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    useSafeArea: false,
    builder: (context) => buildTabSafeSheet(
      context: context,
      child: const _AddFoodMethodSheet(),
    ),
  );
}

class _AddFoodMethodSheet extends StatelessWidget {
  const _AddFoodMethodSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: UIColors.separate,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          20.gap,
          AppText.bold(
            context.tr(LocaleKeys.nutrition_add_method_title),
            fontSize: 16,
          ),
          4.gap,
          AppText.regular(
            context.tr(LocaleKeys.nutrition_add_method_subtitle),
            fontSize: 12,
            color: UIColors.textBody,
          ),
          20.gap,
          _MethodItem(
            icon: Icons.search,
            color: UIColors.pink,
            bg: UIColors.pinkLight,
            title: context.tr(LocaleKeys.nutrition_add_method_search_title),
            subtitle: context.tr(
              LocaleKeys.nutrition_add_method_search_subtitle,
            ),
            enabled: true,
            onTap: () => Navigator.pop(context, AddFoodMethod.search),
          ),
          12.gap,
          _MethodItem(
            icon: Icons.mic_none,
            color: UIColors.vibrantBlue,
            bg: const Color(0xFFEDF0FF),
            title: context.tr(LocaleKeys.nutrition_add_method_voice_title),
            subtitle: context.tr(LocaleKeys.nutrition_coming_soon),
            enabled: false,
          ),
          12.gap,
          _MethodItem(
            icon: Icons.document_scanner_outlined,
            color: UIColors.green,
            bg: const Color(0xFFE7F6EC),
            title: context.tr(LocaleKeys.nutrition_add_method_scan_title),
            subtitle: context.tr(LocaleKeys.nutrition_add_method_scan_subtitle),
            enabled: true,
            onTap: () => Navigator.pop(context, AddFoodMethod.scan),
          ),
        ],
      ),
    );
  }
}

class _MethodItem extends StatelessWidget {
  const _MethodItem({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? UIColors.lightCard : UIColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? UIColors.separate : UIColors.lightGray,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: color),
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.medium(title, fontSize: 13.5, color: UIColors.text),
                3.gap,
                AppText.regular(
                  subtitle,
                  fontSize: 11.5,
                  color: UIColors.textBody,
                ),
              ],
            ),
          ),
          8.gap,
          enabled
              ? Assets.svg.icChevronRight.svg(
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    UIColors.textBody,
                    BlendMode.srcIn,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );

    if (!enabled) {
      return Opacity(opacity: 0.55, child: content);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
