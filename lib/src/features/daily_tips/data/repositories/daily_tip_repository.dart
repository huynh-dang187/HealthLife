import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:healthlife/src/features/daily_tips/data/models/daily_tips_model.dart';
import 'package:intl/intl.dart';

class DailyTipRepository {
  static const _localAssetPath = 'assets/data/daily_tips.json';

  /// Ưu tiên Firestore, fallback JSON local theo modulo
  Future<DailyTip?> getTodayTip() async {
    final fromRemote = await _getFromFirestore();
    if (fromRemote != null) return fromRemote;
    return _getLocalByDay();
  }

  Future<DailyTip?> _getFromFirestore() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
      final doc = await FirebaseFirestore.instance
          .collection('daily_tips')
          .doc(today)
          .get();
      if (!doc.exists) return null;
      return DailyTip.fromFirestore(doc);
    } catch (_) {
      return null; //ofline fallback
    }
  }

  Future<DailyTip> _getLocalByDay() async {
    final raw = await rootBundle.loadString(_localAssetPath);
    final list = (jsonDecode(raw) as List)
        .map((e) => DailyTip.fromJson(e as Map<String, dynamic>))
        .toList();
    if (list.isEmpty) return const DailyTip(tip: 'Chăm sóc sức khỏe mỗi ngày');
    final index = DateTime.now().day % list.length;
    return list[index];
  }
}
