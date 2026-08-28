import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import 'text.dart';

class AppButton extends ElevatedButton {
  AppButton.widget({
    super.key,
    required Widget super.child,
    required VoidCallback onTap,
    bool enable = true,
    Alignment alignment = Alignment.centerLeft,
  }) : super(
         onPressed: enable ? onTap : null,
         style: ButtonStyle(
           padding: WidgetStateProperty.all(EdgeInsets.zero),
           foregroundColor: WidgetStateProperty.all(Colors.white.withAlpha(0)),
           backgroundColor: WidgetStateProperty.all(Colors.white.withAlpha(0)),
           overlayColor: WidgetStateProperty.all(Colors.white.withAlpha(0)),
           elevation: WidgetStateProperty.all(0),
           minimumSize: WidgetStateProperty.all(Size.zero),
           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
           alignment: alignment,
           visualDensity: VisualDensity.compact,
         ),
       );

  AppButton.fill({
    super.key,
    required VoidCallback onTap,
    String? title,
    bool enable = true,
    EdgeInsets titlePadding = EdgeInsets.zero,
    double? width,
    Widget? titleWidget,
    bool hideKeyboardWhenClick = false,
    Color? color,
    BorderRadius? borderRadius,
    double? fontSize,
    double height = 46,
    FontWeight? fontWeight,
  }) : super(
         onPressed: () {
           if (hideKeyboardWhenClick) {
             FocusManager.instance.primaryFocus?.unfocus();
           }
           onTap();
         },
         style: ButtonStyle(
           padding: WidgetStateProperty.all(EdgeInsets.zero),
           shape: WidgetStateProperty.all<RoundedRectangleBorder>(
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           ),
           backgroundColor: WidgetStateProperty.all(
             enable ? (color ?? UIColors.coral) : UIColors.white.withAlpha(20),
           ),
           elevation: WidgetStateProperty.all(0),
           overlayColor: WidgetStateProperty.all(
             enable ? UIColors.text.withAlpha(20) : Colors.transparent,
           ),
           minimumSize: WidgetStateProperty.all(const Size(0, 32)),
           visualDensity: VisualDensity.compact,
         ),
         child: Container(
           height: height,
           width: width,
           padding: titlePadding,
           alignment: Alignment.center,
           decoration: BoxDecoration(
             color: enable
                 ? (color ?? UIColors.coral)
                 : UIColors.text.withAlpha(10),
             borderRadius: BorderRadius.circular(10),
           ),
           child: FittedBox(
             fit: BoxFit.scaleDown,
             child:
                 titleWidget ??
                 AppText.semiBold(
                   title ?? '',
                   color: enable ? Colors.white : Colors.white.withAlpha(150),
                   fontSize: fontSize ?? 15,
                   fontWeight: fontWeight,
                 ),
           ),
         ),
       );

  AppButton.outline({
    super.key,
    required VoidCallback onTap,
    String? title,
    bool isYellow = false,
    bool enable = true,
    Widget? titleWidget,
    EdgeInsets titlePadding = EdgeInsets.zero,
    double? fontSize,
    double height = 46,
    double? width,
    FontWeight? fontWeight,
  }) : super(
         onPressed: () => onTap(),
         style: ButtonStyle(
           padding: WidgetStateProperty.all(EdgeInsets.zero),
           shape: WidgetStateProperty.all<RoundedRectangleBorder>(
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           ),
           backgroundColor: WidgetStateProperty.all(Colors.transparent),
           elevation: WidgetStateProperty.all(0),
           overlayColor: WidgetStateProperty.all(
             enable ? UIColors.green.withAlpha(30) : Colors.transparent,
           ),
           visualDensity: VisualDensity.compact,
         ),
         child: Container(
           height: height,
           width: width,
           alignment: Alignment.center,
           decoration: BoxDecoration(
             border: Border.all(
               color: enable ? UIColors.coral : UIColors.text.withAlpha(50),
             ),
             borderRadius: BorderRadius.circular(10),
           ),
           child: FittedBox(
             fit: BoxFit.scaleDown,
             child:
                 titleWidget ??
                 AppText.semiBold(
                   title ?? '',
                   fontSize: fontSize ?? 14,
                   color: enable
                       ? UIColors.green
                       : UIColors.text.withAlpha(100),
                   fontWeight: fontWeight,
                 ),
           ),
         ),
       );
}
