enum ActivityPeriod {
  week('Tuần', '11 thg 8 - 17 thg 8'),
  month('Tháng', 'thg 8'),
  year('Năm', '2026');

  const ActivityPeriod(this.label, this.rangeLabel);

  final String label;
  final String rangeLabel;
}