import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/medical_place.dart';

class HospitalFinderLocalDataSource {
  static const String _historyKey = 'SEARCH_HISTORY_PLACES';

  Future<void> savePlaceToHistory(MedicalPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistoryPlaces();

    history.removeWhere((item) => item.id == place.id);
    history.insert(0, place);

    final limitedHistory = history.take(10).toList();
    final jsonList = limitedHistory.map((e) => e.toJson()).toList();

    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  Future<List<MedicalPlace>> getHistoryPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => MedicalPlace.fromJson(e)).toList();
  }
}