import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/common/extensions/color_extension.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/fonts.gen.dart';
import '../../../common/constants/colors.dart';
import 'text.dart';

class AppTF extends Column {
  AppTF.common({
    super.key,
    required TextEditingController controller,
    String? label,
    String? hintText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    bool showInfo = false,
    VoidCallback? onTapInfo,
    bool autofocus = false,
    FocusNode? focusNode,
    Widget? leftWidget,
    Widget? rightWidget,
    Color? bgColor,
    Color? textColor,
    double? height,
  }) : super(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             height: height ?? 46,
             padding: const EdgeInsets.symmetric(horizontal: 12),
             decoration: BoxDecoration(
               color: bgColor,
               border: bgColor != null
                   ? null
                   : Border.all(color: UIColors.separate),
               borderRadius: BorderRadius.circular(12),
             ),
             alignment: Alignment.centerLeft,
             child: Row(
               children: [
                 if (leftWidget != null)
                   Padding(
                     padding: const EdgeInsets.only(right: 12),
                     child: leftWidget,
                   ),
                 Expanded(
                   child: TextField(
                     cursorWidth: 1,
                     autofocus: autofocus,
                     cursorHeight: 16,
                     cursorColor: textColor ?? UIColors.text,
                     controller: controller,
                     focusNode: focusNode,
                     decoration: InputDecoration(
                       contentPadding: const EdgeInsets.only(bottom: 2),
                       hintText: (hintText != null) ? tr(hintText) : null,
                       hintStyle: TextStyle(
                         color: textColor?.withAlpha(100) ?? UIColors.textBody,
                         fontSize: 14,
                         fontFamily: FontFamily.inter,
                       ),
                       border: InputBorder.none,
                     ),
                     autocorrect: false,
                     style: TextStyle(
                       color: textColor ?? UIColors.text,
                       fontWeight: FontWeight.w500,
                       fontSize: 14,
                       fontFamily: FontFamily.inter,
                     ),
                     textInputAction: TextInputAction.done,
                     keyboardType: keyboardType,
                     onChanged: onChanged,
                     onSubmitted: onSubmitted,
                     keyboardAppearance: Brightness.dark,
                   ),
                 ),
                 if (rightWidget != null)
                   Padding(
                     padding: const EdgeInsets.only(left: 12),
                     child: rightWidget,
                   ),
               ],
             ),
           ),
         ],
       );

  AppTF.password({
    super.key,
    required TextEditingController controller,
    String? label,
    String? hintText,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    bool showPassword = false,
    VoidCallback? onChangeShowPassword,
    Color? bgColor,
    Color? textColor,
  }) : super(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Container(
             height: 46,
             padding: const EdgeInsets.symmetric(horizontal: 16),
             decoration: BoxDecoration(
               color: bgColor,
               border: bgColor != null
                   ? null
                   : Border.all(color: UIColors.separate),
               borderRadius: BorderRadius.circular(12),
             ),
             alignment: Alignment.centerLeft,
             child: Row(
               children: [
                 Expanded(
                   child: TextField(
                     cursorWidth: 1,
                     autofocus: false,
                     obscureText: !showPassword,
                     cursorHeight: 16,
                     cursorColor: textColor ?? UIColors.text,
                     controller: controller,
                     decoration: InputDecoration(
                       contentPadding: const EdgeInsets.only(bottom: 2),
                       hintText: (hintText != null) ? tr(hintText) : null,
                       hintStyle: TextStyle(
                         color: (textColor ?? UIColors.text).withAlpha(100),
                         fontSize: 14,
                         fontFamily: FontFamily.inter,
                         fontWeight: FontWeight.normal,
                       ),
                       border: InputBorder.none,
                     ),
                     autocorrect: false,
                     style: TextStyle(
                       color: textColor ?? UIColors.text,
                       fontWeight: FontWeight.w500,
                       fontSize: 14,
                       fontFamily: FontFamily.inter,
                     ),
                     textInputAction: TextInputAction.done,
                     keyboardType: keyboardType,
                     onChanged: onChanged,
                     onSubmitted: onSubmitted,
                     keyboardAppearance: Brightness.dark,
                   ),
                 ),
                 AppButton.widget(
                   child: Padding(
                     padding: const EdgeInsets.all(8),
                     child:
                         (showPassword
                                 ? Assets.svg.icEyeOn
                                 : Assets.svg.icEyeOff)
                             .svg(
                               colorFilter: (textColor ?? UIColors.text).filter,
                             ),
                   ),
                   onTap: () {
                     if (onChangeShowPassword != null) {
                       onChangeShowPassword();
                     }
                   },
                 ),
               ],
             ),
           ),
         ],
       );

  AppTF.disable({super.key, String? label, required String value})
    : super(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: UIColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: AppText.medium(value),
          ),
        ],
      );
}
