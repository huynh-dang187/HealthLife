import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/button.dart';
import '../../../../core/presentation/widgets/text.dart';

class CustomWaterDialog extends StatefulWidget {
  final Function(int amount) onConfirm;

  const CustomWaterDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<CustomWaterDialog> createState() => _CustomWaterDialogState();
}

class _CustomWaterDialogState extends State<CustomWaterDialog> {
  final TextEditingController _controller =
      TextEditingController(text: '250');
  int _currentAmount = 250;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final val = int.tryParse(_controller.text);
      if (val != null && val >= 0) {
        _currentAmount = val;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjustAmount(int delta) {
    setState(() {
      _currentAmount = (_currentAmount + delta).clamp(10, 2000);
      _controller.text = _currentAmount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.water_drop, color: Color(0xFF0288D1)),
          8.gap,
          AppText.bold(
            context.tr(LocaleKeys.water_reminder_custom_amount),
            fontSize: 18,
            color: UIColors.text,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _adjustAmount(-50),
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
                color: const Color(0xFF0288D1),
              ),
              8.gap,
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0288D1),
                  ),
                  decoration: const InputDecoration(
                    suffixText: 'ml',
                    suffixStyle: TextStyle(fontSize: 14, color: UIColors.textBody),
                    border: InputBorder.none,
                  ),
                ),
              ),
              8.gap,
              IconButton(
                onPressed: () => _adjustAmount(50),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
                color: const Color(0xFF0288D1),
              ),
            ],
          ),
          16.gap,
          Wrap(
            spacing: 8,
            children: [50, 100, 200, 500].map((preset) {
              return ActionChip(
                label: AppText.medium('+$preset ml', color: const Color(0xFF0288D1)),
                onPressed: () => _adjustAmount(preset),
                backgroundColor: const Color(0xFFE1F5FE),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 80,
              child: AppButton.outline(
                onTap: () => Navigator.of(context).pop(),
                title: context.tr(LocaleKeys.water_reminder_cancel),
                height: 38,
              ),
            ),
            12.gap,
            SizedBox(
              width: 90,
              child: AppButton.fill(
                onTap: () {
                  if (_currentAmount > 0) {
                    widget.onConfirm(_currentAmount);
                    Navigator.of(context).pop();
                  }
                },
                title: context.tr(LocaleKeys.water_reminder_add),
                color: const Color(0xFF0288D1),
                height: 38,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

