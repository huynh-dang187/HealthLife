/// Một ô thống kê: label nhỏ trên cùng, giá trị chính, dòng phụ.
class ActivityStatItem {
  const ActivityStatItem({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;
}