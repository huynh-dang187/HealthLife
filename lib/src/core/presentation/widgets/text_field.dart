import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/color_extension.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? UIColors.darkTextPrimary : UIColors.lightTextPrimary;
    final secondaryColor =
        isDark ? UIColors.darkTextSecondary : UIColors.lightTextSecondary;
    final fillColor = isDark ? UIColors.darkSurface : UIColors.lightSurface;
    final borderColor = isDark ? UIColors.darkBorder : UIColors.lightBorder;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      cursorColor: UIColors.pink,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: secondaryColor),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: secondaryColor),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon ?? _buildSuffix(),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(borderColor),
        enabledBorder: _border(borderColor),
        focusedBorder: _border(UIColors.pink, width: 1.5),
        disabledBorder: _border(borderColor),
        errorBorder: _border(UIColors.coral),
        focusedErrorBorder: _border(UIColors.coral, width: 1.5),
        errorStyle: const TextStyle(color: UIColors.coral),
      ),
    );
  }

  Widget? _buildSuffix() {
    if (!widget.obscureText) return null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? UIColors.darkTextSecondary : UIColors.lightTextSecondary;

    return IconButton(
      onPressed: () => setState(() => _obscured = !_obscured),
      icon: (_obscured ? Assets.svg.icEyeOff : Assets.svg.icEyeOn).svg(
        width: 22,
        height: 22,
        colorFilter: iconColor.filter,
      ),
    );
  }
}
