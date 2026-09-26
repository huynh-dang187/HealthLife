import 'package:equatable/equatable.dart';

class WaterLogModel extends Equatable {
  final String id;
  final int amount; // ml
  final DateTime timestamp;
  final String dateString; // YYYY-MM-DD theo múi giờ Việt Nam (UTC+7)

  WaterLogModel({
    required this.id,
    required this.amount,
    required this.timestamp,
    String? dateString,
  }) : dateString = dateString ?? formatDateToVietnamString(timestamp);

  /// Chuyển đổi DateTime sang định dạng YYYY-MM-DD theo múi giờ Việt Nam (UTC+7)
  static String formatDateToVietnamString(DateTime dt) {
    final vnTime = dt.toUtc().add(const Duration(hours: 7));
    final year = vnTime.year.toString().padLeft(4, '0');
    final month = vnTime.month.toString().padLeft(2, '0');
    final day = vnTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Lấy ngày hiện tại dạng YYYY-MM-DD theo múi giờ Việt Nam (UTC+7)
  static String getTodayVietnamDateString() {
    return formatDateToVietnamString(DateTime.now());
  }

  WaterLogModel copyWith({
    String? id,
    int? amount,
    DateTime? timestamp,
    String? dateString,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      dateString: dateString ?? this.dateString,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'dateString': dateString,
    };
  }

  factory WaterLogModel.fromMap(Map<dynamic, dynamic> map) {
    return WaterLogModel(
      id: map['id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dateString: map['dateString'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, amount, timestamp, dateString];
}
