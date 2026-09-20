/// Một cột dữ liệu cho biểu đồ bước chân.
class StepChartData {
  const StepChartData({
    required this.label,
    required this.steps,
    required this.goalReached,
  });

  final String label;
  final int steps;
  final bool goalReached;
}