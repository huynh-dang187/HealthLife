import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

import '../../data/model/food_model.dart';

/// Hiện bottom sheet nhập gram / số phần ăn cho [food], trả [true] nếu
/// đã thêm thành công vào nhật ký (gọi qua [onAdd]).
Future<bool> showAddFoodAmountSheet(
  BuildContext context, {
  required FoodModel food,
  required Future<bool> Function(double grams) onAdd,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: UIColors.lightCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: _AddFoodAmountSheet(food: food, onAdd: onAdd),
    ),
  ).then((added) => added ?? false);
}

class _AddFoodAmountSheet extends StatefulWidget {
  const _AddFoodAmountSheet({required this.food, required this.onAdd});

  final FoodModel food;
  final Future<bool> Function(double grams) onAdd;

  @override
  State<_AddFoodAmountSheet> createState() => _AddFoodAmountSheetState();
}

class _AddFoodAmountSheetState extends State<_AddFoodAmountSheet> {
  late final TextEditingController _gramsController;
  bool _saving = false;

  double get _serving => widget.food.servingG;

  double get _grams =>
      double.tryParse(_gramsController.text.replaceAll(',', '.')) ?? 0;

  @override
  void initState() {
    super.initState();
    _gramsController = TextEditingController(
      text: _serving.round().toString(),
    );
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _setGrams(double grams) {
    if (grams <= 0) return;
    _gramsController.text = grams == grams.roundToDouble()
        ? grams.round().toString()
        : grams.toString();
  }

  Future<void> _submit() async {
    final grams = _grams;
    if (grams <= 0 || _saving) return;

    setState(() => _saving = true);
    final ok = await widget.onAdd(grams);
    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thêm thực phẩm, thử lại sau')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.food.nutrientsFor(_serving);
    final scaled = widget.food.nutrientsFor(_grams);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          AppText.bold(widget.food.name, fontSize: 16, maxLines: 2),
          4.gap,
          AppText.regular(
            '${widget.food.group} • ~${base.calo.round()} kcal/${_format(_serving)}g',
            fontSize: 11.5,
            color: UIColors.textBody,
          ),
          20.gap,
          Row(
            children: [
              _RoundBtn(
                icon: Icons.remove,
                onTap: _grams - _step() > 0
                    ? () => _setGrams(_grams - _step())
                    : null,
              ),
              10.gap,
              Expanded(child: _gramsField()),
              10.gap,
              _RoundBtn(
                icon: Icons.add,
                onTap: () => _setGrams(_grams + _step()),
                accent: true,
              ),
            ],
          ),
          12.gap,
          Row(
            children: [
              _quickChip('1 phần (${_format(_serving)}g)'),
              8.gap,
              _quickChip('Nửa phần (${_format(_serving / 2)}g)'),
              8.gap,
              _quickChip('2 phần (${_format(_serving * 2)}g)'),
            ],
          ),
          20.gap,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UIColors.lightGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.regular(
                      'Tổng năng lượng',
                      fontSize: 12,
                      color: UIColors.textBody,
                    ),
                    AppText.semiBold(
                      '~${scaled.calo.round()} kcal',
                      fontSize: 13,
                      color: UIColors.pink,
                    ),
                  ],
                ),
                8.gap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ValueCell('Đạm', '${scaled.protein.round()}g'),
                    _ValueCell('Carbs', '${scaled.carb.round()}g'),
                    _ValueCell('Chất béo', '${scaled.fat.round()}g'),
                    _ValueCell('Chất xơ', '${scaled.fiber.round()}g'),
                  ],
                ),
              ],
            ),
          ),
          20.gap,
          AppButton.fill(
            title: 'Thêm vào nhật ký',
            height: 48,
            enable: _grams > 0 && !_saving,
            borderRadius: BorderRadius.circular(16),
            onTap: _submit,
            titleWidget: _saving
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(UIColors.white),
                        ),
                      ),
                      8.gap,
                      AppText.semiBold('Đang thêm...', color: UIColors.white),
                    ],
                  )
                : AppText.semiBold(
                    'Thêm vào nhật ký',
                    fontSize: 15,
                    color: UIColors.white,
                  ),
          ),
        ],
      ),
    );
  }

  double _step() => (_serving / 5).clamp(5.0, 200.0);

  Widget _gramsField() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: UIColors.lightGray,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: UIColors.separate),
    ),
    alignment: Alignment.center,
    child: TextField(
      controller: _gramsController,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: UIColors.text,
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
      ),
      onChanged: (_) => setState(() {}),
    ),
  );

  Widget _quickChip(String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _serving > 0
          ? () {
              final grams = label.contains('Nửa')
                  ? _serving / 2
                  : label.contains('2 phần')
                  ? _serving * 2
                  : _serving;
              setState(() => _setGrams(grams));
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: UIColors.separate),
        ),
        child: AppText.medium(label, fontSize: 10.5, color: UIColors.pink),
      ),
    );
  }

  static String _format(double v) => v == v.roundToDouble()
      ? v.round().toString()
      : v.toStringAsFixed(1);
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.35 : 1,
      child: Material(
        color: accent ? UIColors.pink : UIColors.lightGray,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 20,
              color: accent ? UIColors.white : UIColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText.medium(value, fontSize: 11.5, color: UIColors.text),
        2.gap,
        AppText.regular(label, fontSize: 9.5, color: UIColors.textBody),
      ],
    );
  }
}