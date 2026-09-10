import 'package:healthlife/src/features/daily_tips/data/models/daily_tips_model.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class DailyTipState {
  final BlocStatus status;
  final String? message;
  final DailyTip? tip;

  /// Text hiển thị, fallback khi chưa có/trống.
  String get displayTip {
    final t = tip?.tip.trim();
    return (t?.isNotEmpty ?? false) ? t! : 'Chăm sóc sức khỏe mỗi ngày bạn nhé';
  }

  /// Emoji hiển thị, null → dùng icon mặc định.
  String? get displayEmoji {
    final e = tip?.emoji?.trim();
    return (e?.isNotEmpty ?? false) ? e : null;
  }

  const DailyTipState({
    this.status = BlocStatus.initial,
    this.message,
    this.tip,
  });

  DailyTipState copyWith({
    BlocStatus? status,
    String? message,
    DailyTip? tip,
  }) {
    return DailyTipState(
      status: status ?? this.status,
      message: message ?? this.message,
      tip: tip ?? this.tip,
    );
  }
}
