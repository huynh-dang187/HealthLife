import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/count_steep/presentation/cubit/activity_dashboard_cubit.dart';

Future<int?> showSetGoalDialog(
  BuildContext context, {
  required ActivityDashboardCubit cubit,
  int initialGoal = 6000,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? UIColors.darkSurface
        : UIColors.lightCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _SetGoalSheet(cubit: cubit, initialGoal: initialGoal),
  );
}

class _SetGoalSheet extends StatefulWidget {
  const _SetGoalSheet({required this.cubit, required this.initialGoal});

  final ActivityDashboardCubit cubit;
  final int initialGoal;

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
    final initialIndex = _nearestIndex(widget.initialGoal);
    _selected = _values[initialIndex];
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  int _nearestIndex(int target) {
    final clamped = target.clamp(_min, _max);
    var nearest = 0;
    var bestDiff = _values[0] - clamped;
    for (var i = 1; i < _values.length; i++) {
      final diff = (_values[i] - clamped).abs();
      if (diff < bestDiff.abs()) {
        nearest = i;
        bestDiff = diff;
      }
    }
    return nearest;
  }

  void _stepBy(int delta) {
    final index = _values.indexOf(_selected) + delta;
    if (index < 0 || index >= _values.length) return;
    _scrollController.animateToItem(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
    setState(() => _selected = _values[index]);
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
              onTap: _save,
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

  Future<void> _save() async {
    debugPrint('SET_GOAL: lưu $_selected bước');
    await widget.cubit.updateStepGoal(_selected);
    if (!mounted) return;
    Navigator.pop(context, _selected);
  }

  Widget _buildPicker() {
    final index = _values.indexOf(_selected);
    final canPrev = index > 0;
    final canNext = index < _values.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onTap: canPrev ? () => _stepBy(-1) : null,
        ),
        12.gap,
        Expanded(
          child: Container(
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
          ),
        ),
        12.gap,
        _StepperButton(
          icon: Icons.add,
          onTap: canNext ? () => _stepBy(1) : null,
        ),
      ],
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

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      color: enabled
          ? UIColors.white
          : UIColors.textBody.withValues(alpha: 0.4),
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: UIColors.pink,
        disabledBackgroundColor: UIColors.separate,
      ),
    );
  }
}
