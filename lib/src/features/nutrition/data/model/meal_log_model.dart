import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Một bữa đã được thêm vào nhật ký ăn của user.
///
/// Lưu tại `users/{uid}/meal_logs/{logId}`.
/// `date` lưu dạng chuỗi `yyyy-MM-dd` để query đúng theo ngày/khoảng.
class MealLogModel extends Equatable {
  const MealLogModel({
    required this.id,
    required this.foodName,
    required this.calo,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.fiber,
    required this.grams,
    required this.mealTime,
    this.foodId,
  });

  final String id;
  final String? foodId;
  final String foodName;
  final double calo;
  final double protein;
  final double fat;
  final double carb;
  final double fiber;
  final double grams;
  final DateTime mealTime;

  DateTime get date => DateTime(
    mealTime.year,
    mealTime.month,
    mealTime.day,
  );

  String get dateKey => DateFormat('yyyy-MM-dd').format(mealTime);

  factory MealLogModel.fromMap(Map<String, dynamic> map, String id) {
    double n(Object? v) => v is num ? v.toDouble() : 0;

    return MealLogModel(
      id: id,
      foodId: map['foodId'] as String?,
      foodName: map['foodName'] as String? ?? '',
      calo: n(map['calo']),
      protein: n(map['protein']),
      fat: n(map['fat']),
      carb: n(map['carb']),
      fiber: n(map['fiber']),
      grams: n(map['grams']),
      mealTime:
          (map['mealTime'] as Timestamp?)?.toDate().toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'foodId': foodId,
    'foodName': foodName,
    'calo': calo,
    'protein': protein,
    'fat': fat,
    'carb': carb,
    'fiber': fiber,
    'grams': grams,
    'mealTime': Timestamp.fromDate(mealTime),
    'date': dateKey,
  };

  @override
  List<Object?> get props => [
    id,
    foodId,
    foodName,
    calo,
    protein,
    fat,
    carb,
    fiber,
    grams,
    mealTime,
  ];
}
