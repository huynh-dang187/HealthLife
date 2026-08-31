import 'package:flutter/material.dart';
import 'package:healthlife/src/common/extensions/color_extension.dart';

import '../../../../generated/assets.gen.dart';
import '../../../common/constants/colors.dart';
import '../../../common/extensions/num_x.dart';
import 'text.dart';

class NoData extends StatelessWidget {
  const NoData({
    super.key,
    this.height,
    this.title,
    this.iconSize,
    this.fontSize,
  }) : isList = false;

  final double? height;
  final String? title;
  final double? iconSize;
  final double? fontSize;
  final bool isList;

  Widget get content => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Assets.svg.icClose.svg(
        colorFilter: UIColors.green.filter,
        width: iconSize ?? 28,
      ),
      8.gap,
      AppText.italic(
        title ?? "Không có dữ liệu",
        color: UIColors.textBody,
        textAlign: TextAlign.center,
        fontSize: fontSize ?? 14,
        fontWeight: FontWeight.w500,
      ),
      16.gap,
    ],
  );

  const NoData.list({
    super.key,
    this.title,
    this.iconSize,
    this.fontSize,
  }) : isList = true,
       height = null;

  @override
  Widget build(BuildContext context) {
    return isList
        ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: content,
                ),
              ),
            ],
          )
        : SizedBox(
            height: height,
            child: Center(
              child: content,
            ),
          );
  }
}
