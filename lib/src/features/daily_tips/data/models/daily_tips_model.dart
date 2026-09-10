import 'package:cloud_firestore/cloud_firestore.dart';

class DailyTip {
  final String tip;
  final String? category;
  final String? emoji;

  const DailyTip({
    required this.tip,
    this.category,
    this.emoji,
  });

  //Từ Json
  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      tip: json['tip'] as String,
      category: json['category'] as String?,
      emoji: json['emoji'] as String?,
    );
  }

  /// Từ Firestore
  factory DailyTip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DailyTip(
      tip: data['tip'] as String? ?? '',
      category: data['category'] as String?,
      emoji: data['emoji'] as String?,
    );
  }
}
