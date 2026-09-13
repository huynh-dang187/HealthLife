import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/food_nutrition_model.dart';

class GeminiScanRemoteDataSource {
  late final GenerativeModel _model;

  GeminiScanRemoteDataSource({String? apiKey}) {
    final key = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

    _model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  static const String _systemInstruction = '''
Phân tích dữ liệu và trả về duy nhất chuỗi JSON (không chứa mã markdown ```json):
{
  "is_food": boolean,
  "error_message": string hoặc null, 
  "food_name": string,
  "calories": number,
  "protein_g": number,
  "fat_g": number,
  "carbs_g": number,
  "assessment": string 
}
''';

  /// Phân tích dinh dưỡng qua hình ảnh món ăn
  Future<FoodNutritionModel> analyzeFoodImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final promptPart = TextPart(_systemInstruction);
    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = await _model.generateContent([
      Content.multi([promptPart, imagePart])
    ]);

    return _parseResponse(response.text);
  }

  /// Phân tích dinh dưỡng qua tên món ăn nhập tay
  Future<FoodNutritionModel> analyzeFoodText(String foodName) async {
    final prompt = '$_systemInstruction\n\nPhân tích dinh dưỡng món ăn: "$foodName"';
    final response = await _model.generateContent([Content.text(prompt)]);
    return _parseResponse(response.text);
  }

  FoodNutritionModel _parseResponse(String? text) {
    if (text == null || text.trim().isEmpty) {
      return const FoodNutritionModel(
        isFood: false,
        errorMessage: 'Không nhận được phản hồi từ AI.',
      );
    }
    try {
      String cleanJson = text.replaceAll(RegExp(r'^```json|```$'), '').trim();
      return FoodNutritionModel.fromJson(jsonDecode(cleanJson));
    } catch (e) {
      return const FoodNutritionModel(
        isFood: false,
        errorMessage: 'Dữ liệu phản hồi từ AI không đúng cấu trúc.',
      );
    }
  }
}