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

  static const _primaryColor = Color(0xFF0288D1);
  static const _lightBlue = Color(0xFFE3F5FC);

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
      initialTime: TimeOfDay(
        hour: initialHour,
        minute: initialMinute,
      ),
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 20),

      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lightBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: _primaryColor,
              size: 23,
            ),
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bold(
                  'Cài đặt nhắc nhở',
                  fontSize: 18,
                  color: UIColors.text,
                ),
                2.gap,
                AppText.regular(
                  'Thiết lập mục tiêu và lịch uống nước',
                  fontSize: 12,
                  color: UIColors.textBody,
                ),
              ],
            ),
          ),
        ],
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.gap,
            _buildSectionTitle(
              icon: Icons.flag_rounded,
              title: 'Mục tiêu hàng ngày',
            ),

            10.gap,

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE0EEF4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_drink_rounded,
                      color: _primaryColor,
                      size: 21,
                    ),
                  ),
                  12.gap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.medium(
                          'Lượng nước mục tiêu',
                          fontSize: 12,
                          color: UIColors.textBody,
                        ),
                        6.gap,
                        TextField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: UIColors.text,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            suffixText: 'ml',
                            suffixStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: UIColors.textBody,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed > 0) {
                              _goal = parsed;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            20.gap,

            _buildSectionTitle(
              icon: Icons.notifications_active_rounded,
              title: 'Nhắc nhở uống nước',
            ),

            10.gap,

            Container(
              decoration: BoxDecoration(
                color: _isReminderEnabled
                    ? const Color(0xFFF4FAFD)
                    : const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isReminderEnabled
                      ? const Color(0xFFD8EDF7)
                      : const Color(0xFFEAEAEA),
                ),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                dense: true,
                title: AppText.semiBold(
                  'Bật thông báo nhắc nhở',
                  fontSize: 14,
                  color: UIColors.text,
                ),
                subtitle: AppText.regular(
                  _isReminderEnabled
                      ? 'Đang bật lịch nhắc nhở'
                      : 'Thông báo đang tắt',
                  fontSize: 11,
                  color: UIColors.textBody,
                ),
                value: _isReminderEnabled,
                activeColor: _primaryColor,
                onChanged: (val) {
                  setState(() {
                    _isReminderEnabled = val;
                  });
                },
              ),
            ),
            if (_isReminderEnabled) ...[
              18.gap,

              _buildSectionTitle(
                icon: Icons.schedule_rounded,
                title: 'Lịch nhắc nhở',
              ),

              10.gap,

              // Interval
              AppText.medium(
                'Tần suất nhắc nhở',
                fontSize: 12,
                color: UIColors.textBody,
              ),

              6.gap,

              DropdownButtonFormField<int>(
                value: _intervalHours,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _primaryColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7FBFD),
                  prefixIcon: const Icon(
                    Icons.update_rounded,
                    color: _primaryColor,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0EEF4),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0EEF4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: _primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: AppText.regular('Mỗi 1 giờ'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: AppText.regular('Mỗi 2 giờ'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: AppText.regular('Mỗi 3 giờ'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: AppText.regular('Mỗi 4 giờ'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _intervalHours = val;
                    });
                  }
                },
              ),

              16.gap,

              AppText.medium(
                'Khung giờ nhắc nhở',
                fontSize: 12,
                color: UIColors.textBody,
              ),

              8.gap,

              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Bắt đầu',
                      time: _startTime,
                      icon: Icons.wb_sunny_outlined,
                      onTap: () => _selectTime(true),
                    ),
                  ),
                  10.gap,
                  Expanded(
                    child: _buildTimePicker(
                      label: 'Kết thúc',
                      time: _endTime,
                      icon: Icons.nightlight_outlined,
                      onTap: () => _selectTime(false),
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
          children: [
            Expanded(
              child: AppButton.outline(
                onTap: () => Navigator.of(context).pop(),
                title: 'Hủy',
                height: 44,
              ),
            ),
            10.gap,
            Expanded(
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
                title: 'Lưu cài đặt',
                color: _primaryColor,
                height: 44,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: _primaryColor,
        ),
        7.gap,
        AppText.semiBold(
          title,
          fontSize: 14,
          color: UIColors.text,
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE0EEF4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: _primaryColor,
              ),
            ),
            9.gap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.regular(
                    label,
                    fontSize: 11,
                    color: UIColors.textBody,
                  ),
                  2.gap,
                  AppText.semiBold(
                    time,
                    fontSize: 15,
                    color: UIColors.text,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
