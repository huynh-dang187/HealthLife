import 'package:healthlife/src/features/daily_tips/data/models/daily_tips_model.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

final class DailyTipState {
  final BlocStatus status;
  final String? message;
  final DailyTip? tip;

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
