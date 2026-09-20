import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

Future<int?> showSetGoalDialog(BuildContext context) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? UIColors.darkSurface
        : UIColors.lightCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _SetGoalSheet(),
  );
}

class _SetGoalSheet extends StatefulWidget {
  const _SetGoalSheet();

  @override
  State<_SetGoalSheet> createState() => _SetGoalSheetState();
}

class _SetGoalSheetState extends State<_SetGoalSheet> {
  static const _min = 1000;
  static const _max = 20000;
  static const _step = 500;

  late int _selected;
  late final List<int> _values;
  late final FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _values = [
      for (var v = _min; v <= _max; v += _step) v,
    ];
    final defaultIndex = _values.indexOf(6000);
    _selected = _values[defaultIndex >= 0 ? defaultIndex : _values.length ~/ 2];
    _scrollController = FixedExtentScrollController(
      initialItem: _values.indexOf(_selected),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UIColors.separate,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            20.gap,
            AppText.bold('Đặt mục tiêu', fontSize: 18),
            12.gap,
            _buildPicker(),
            16.gap,
            AppButton.fill(
              title: 'Lưu',
              color: UIColors.pink,
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                debugPrint('SET_GOAL: chọn $_selected bước');
                Navigator.pop(context, _selected);
              },
            ),
            6.gap,
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: AppText.medium(
                'Hủy bỏ',
                fontSize: 15,
                color: UIColors.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: UIColors.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: CupertinoPicker(
        scrollController: _scrollController,
        itemExtent: 44,
        onSelectedItemChanged: (index) {
          setState(() => _selected = _values[index]);
        },
        children: [
          for (final value in _values)
            Center(
              child: value == _selected
                  ? AppText.semiBold(
                      '${_format(value)} bước',
                      fontSize: 20,
                      color: UIColors.black,
                    )
                  : AppText.regular(
                      '${_format(value)} bước',
                      fontSize: 15,
                      color: UIColors.textBody.withValues(alpha: 0.9),
                    ),
            ),
        ],
      ),
    );
  }

  static String _format(int value) {
    final buffer = StringBuffer();
    final s = value.toString();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      buffer.write(s[i]);
      final remaining = len - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}
