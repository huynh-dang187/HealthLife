import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/fonts.gen.dart';
import '../../../common/constants/colors.dart';

class AppText extends StatelessWidget {
  AppText.light(
    String text, {
    Key? key,
    double fontSize = 14,
    Color? color,
    FontWeight? fontWeight = FontWeight.w300,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow = TextOverflow.ellipsis,
    TextDecoration? decoration,
  }) : this._(
         text,
         key: key,
         maxLines: maxLines,
         textAlign: textAlign,
         textOverflow: textOverflow,
         style: TextStyle(
           color: color ?? UIColors.text,
           fontSize: fontSize,
           fontWeight: fontWeight,
           decoration: decoration,
           fontFamily: FontFamily.inter,
         ),
       );

  AppText.italic(
    String text, {
    Key? key,
    double fontSize = 14,
    Color? color,
    FontWeight? fontWeight = FontWeight.w300,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow = TextOverflow.ellipsis,
    TextDecoration? decoration,
  }) : this._(
         text,
         key: key,
         maxLines: maxLines,
         textAlign: textAlign,
         textOverflow: textOverflow,
         style: TextStyle(
           color: color ?? UIColors.text,
           fontSize: fontSize,
           fontWeight: fontWeight,
           decoration: decoration,
           fontStyle: FontStyle.italic,
           fontFamily: FontFamily.inter,
         ),
       );

  AppText.regular(
    String text, {
    Key? key,
    double fontSize = 14,
    Color? color,
    FontWeight? fontWeight = FontWeight.w400,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow = TextOverflow.ellipsis,
    TextDecoration? decoration,
    double? height,
  }) : this._(
         text,
         key: key,
         maxLines: maxLines,
         textAlign: textAlign,
         textOverflow: textOverflow,
         style: TextStyle(
           color: color ?? UIColors.text,
           fontSize: fontSize,
           fontWeight: fontWeight,
           decoration: decoration,
           decorationColor: color ?? UIColors.text,
           height: height,
           fontFamily: FontFamily.inter,
         ),
       );

  AppText.medium(
    String text, {
    Key? key,
    double fontSize = 14,
    Color? color,
    FontWeight? fontWeight = FontWeight.w500,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow = TextOverflow.ellipsis,
    Map<String, String>? namedArgs,
    TextDecoration? decoration,
    double? height,
    double? letterSpacing,
  }) : this._(
         text,
         key: key,
         maxLines: maxLines,
         textAlign: textAlign,
         textOverflow: textOverflow,
         namedArgs: namedArgs,
         style: TextStyle(
           color: color ?? UIColors.text,
           fontSize: fontSize,
           fontWeight: fontWeight,
           decoration: decoration,
           decorationColor: color ?? UIColors.text,
           height: height,
           fontFamily: FontFamily.inter,
           letterSpacing: letterSpacing,
         ),
       );

  AppText.semiBold(
    String text, {
    Key? key,
    double fontSize = 14,
    Color? color,
    FontWeight? fontWeight = FontWeight.w600,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? textOverflow = TextOverflow.ellipsis,
    Map<String, String>? namedArgs,
    TextDecoration? decoration,
    double? height,
    String? fontFamily,
  }) : this._(
         text,
         key: key,
         maxLines: maxLines,
         textAlign: textAlign,
         textOverflow: textOverflow,
         namedArgs: namedArgs,
         style: TextStyle(
           color: color ?? UIColors.text,
           fontSize: fontSize,
           fontWeight: fontWeight,
           decoration: decoration,
           decorationColor: color ?? UIColors.text,
           decorationThickness: 0.5,
           height: height,
           fontFamily: fontFamily ?? FontFamily.inter,
         ),
       );

  AppText.bold(
    String text, {
    Key? key,
    double fontSize = 14,
    Color? color,
    FontWeight? fontWeight = FontWeight.w700,
    int? maxLines,
    TextOverflow? textOverflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
    TextDecoration? decoration,
    double? height,
  }) : this._(
         text,
         key: key,
         maxLines: maxLines,
         textAlign: textAlign,
         textOverflow: textOverflow,
         style: TextStyle(
           color: color ?? UIColors.text,
           fontSize: fontSize,
           fontWeight: fontWeight,
           decoration: decoration,
           height: height,
           fontFamily: FontFamily.inter,
         ),
       );

  const AppText._(
    this.text, {
    required this.style,
    this.namedArgs,
    this.maxLines,
    this.textAlign,
    this.textOverflow,
    super.key,
  });

  final String text;
  final TextStyle style;
  final Map<String, String>? namedArgs;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;

  @override
  Widget build(BuildContext context) {
    // Đăng ký phụ thuộc locale: khi context.setLocale() được gọi,
    // widget này tự build lại -> .tr() dịch lại theo ngôn ngữ mới.
    context.locale;

    return Text(
      text.tr(namedArgs: namedArgs),
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: textOverflow ?? TextOverflow.ellipsis,
    );
  }
}
