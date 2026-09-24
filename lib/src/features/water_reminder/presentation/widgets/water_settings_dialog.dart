import 'package:flutter/material.dart';
import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/button.dart';
import '../../../../core/presentation/widgets/text.dart';
import '../../data/models/water_settings_model.dart';

class WaterSettingsDialog extends StatefulWidget {
  final WaterSettingsModel settings;
  final Function(int newGoal) onGoalUpdated;
  final Function(bool isEnabled) onToggleReminder;
  final Function(String startTime, String endTime, int interval)
      onScheduleUpdated;

  const WaterSettingsDialog({
    super.key,
    required this.settings,
    required this.onGoalUpdated,
    required this.onToggleReminder,
    required this.onScheduleUpdated,
  });

  @override
  State<WaterSettingsDialog> createState() => _WaterSettingsDialogState();
}

class _WaterSettingsDialogState extends State<WaterSettingsDialog> {
  late int _goal;
  late bool _isReminderEnabled;
  late int _intervalHours;
  late String _startTime;
  late String _endTime;

  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _goal = widget.settings.dailyGoal;
    _isReminderEnabled = widget.settings.isReminderEnabled;
    _intervalHours = widget.settings.intervalHours;
    _startTime = widget.settings.startTime;
    _endTime = widget.settings.endTime;

    _goalController.text = _goal.toString();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStart) async {
    final currentStr = isStart ? _startTime : _endTime;
    final parts = currentStr.split(':');
    final initialHour = int.tryParse(parts[0]) ?? (isStart ? 7 : 22);
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      final timeFormatted = '$hourStr:$minuteStr';

      setState(() {
        if (isStart) {
          _startTime = timeFormatted;
        } else {
          _endTime = timeFormatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.settings, color: Color(0xFF0288D1)),
          8.gap,
          AppText.bold(
            'Cài đặt nhắc nhở',
            fontSize: 18,
            color: UIColors.text,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mục tiêu ngày
            AppText.semiBold(
              'Mục tiêu nước hàng ngày (ml)',
              fontSize: 14,
              color: UIColors.text,
            ),
            6.gap,
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'ml',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed > 0) {
                  _goal = parsed;
                }
              },
            ),
            16.gap,
            const Divider(),
            8.gap,

            // Bật / Tắt nhắc nhở
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: AppText.semiBold(
                'Bật thông báo nhắc nhở',
                fontSize: 14,
                color: UIColors.text,
              ),
              value: _isReminderEnabled,
              activeColor: const Color(0xFF0288D1),
              onChanged: (val) {
                setState(() {
                  _isReminderEnabled = val;
                });
              },
            ),

            if (_isReminderEnabled) ...[
              8.gap,

              // Khoảng thời gian lặp lại
              AppText.semiBold(
                'Tần suất nhắc nhở',
                fontSize: 14,
                color: UIColors.text,
              ),
              6.gap,
              DropdownButtonFormField<int>(
                value: _intervalHours,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: AppText.regular('Mỗi 1 giờ')),
                  DropdownMenuItem(value: 2, child: AppText.regular('Mỗi 2 giờ')),
                  DropdownMenuItem(value: 3, child: AppText.regular('Mỗi 3 giờ')),
                  DropdownMenuItem(value: 4, child: AppText.regular('Mỗi 4 giờ')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _intervalHours = val;
                    });
                  }
                },
              ),
              14.gap,

              // Khung giờ nhắc nhở (Bắt đầu - Kết thúc)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.regular(
                          'Bắt đầu',
                          fontSize: 13,
                          color: UIColors.textBody,
                        ),
                        4.gap,
                        OutlinedButton(
                          onPressed: () => _selectTime(true),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: AppText.medium(_startTime),
                        ),
                      ],
                    ),
                  ),
                  12.gap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.regular(
                          'Kết thúc',
                          fontSize: 13,
                          color: UIColors.textBody,
                        ),
                        4.gap,
                        OutlinedButton(
                          onPressed: () => _selectTime(false),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: AppText.medium(_endTime),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 80,
              child: AppButton.outline(
                onTap: () => Navigator.of(context).pop(),
                title: 'Hủy',
                height: 38,
              ),
            ),
            12.gap,
            SizedBox(
              width: 90,
              child: AppButton.fill(
                onTap: () {
                  widget.onGoalUpdated(_goal);
                  widget.onToggleReminder(_isReminderEnabled);
                  if (_isReminderEnabled) {
                    widget.onScheduleUpdated(
                      _startTime,
                      _endTime,
                      _intervalHours,
                    );
                  }
                  Navigator.of(context).pop();
                },
                title: 'Lưu',
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
