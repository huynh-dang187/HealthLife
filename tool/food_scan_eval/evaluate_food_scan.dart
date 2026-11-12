// Harness đánh giá (evaluate) chức năng Food Scan dùng Gemini.
//
// Chạy:
//   PowerShell:  $env:GEMINI_API_KEY="<key>"; fvm dart run tool/food_scan_eval/evaluate_food_scan.dart
//   hoặc:        fvm dart run tool/food_scan_eval/evaluate_food_scan.dart --api-key=<key>
//
// Kết quả ghi ra: tool/food_scan_eval/out/results.csv và out/results.md
//
// LƯU Ý: Đây KHÔNG phải "độ chính xác của model đã train" (Gemini là model đóng
// của Google, mình không train và API không trả về accuracy). Đây là đánh giá
// pipeline của MÌNH trên một tập test có đáp án (ground truth).

import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

const String _modelName = 'gemini-3.6-flash';

const String _systemInstruction = '''
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

class GroundTruthRow {
  GroundTruthRow({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.imagePath,
  });

  final String id;
  final String foodName;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final String imagePath;
}

class Prediction {
  Prediction({
    required this.isFood,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });

  final bool isFood;
  final String foodName;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
}

class EvalRow {
  EvalRow({
    required this.truth,
    this.prediction,
    this.error,
  });

  final GroundTruthRow truth;
  final Prediction? prediction;
  final String? error;

  bool get nameMatched {
    final p = prediction;
    if (p == null || !p.isFood) return false;
    return _nameMatches(truth.foodName, p.foodName);
  }
}

Future<void> main(List<String> args) async {
  final apiKey = _resolveApiKey(args);
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln(
      'Thiếu API key. Đặt biến môi trường GEMINI_API_KEY hoặc truyền --api-key=<key>.',
    );
    exitCode = 64;
    return;
  }

  final baseDir = Directory('tool/food_scan_eval');
  final gtFile = File('${baseDir.path}/ground_truth.csv');
  if (!gtFile.existsSync()) {
    stderr.writeln('Không tìm thấy ${gtFile.path}. Chạy lệnh từ thư mục gốc dự án.');
    exitCode = 66;
    return;
  }

  final rows = _parseGroundTruth(gtFile.readAsStringSync());
  if (rows.isEmpty) {
    stderr.writeln('File ground truth rỗng.');
    exitCode = 65;
    return;
  }

  final model = GenerativeModel(
    model: _modelName,
    apiKey: apiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  stdout.writeln('Đánh giá ${rows.length} mẫu bằng $_modelName ...\n');

  final results = <EvalRow>[];
  for (final truth in rows) {
    stdout.writeln('[${truth.id}] ${truth.foodName} ...');
    try {
      final prediction = await _predictWithRetry(model, truth);
      results.add(EvalRow(truth: truth, prediction: prediction));
      stdout.writeln(
        '    -> "${prediction.foodName}" | ${prediction.calories.toStringAsFixed(0)} kcal '
        '(đúng tên: ${_nameMatches(truth.foodName, prediction.foodName) ? "CÓ" : "KHÔNG"})',
      );
    } catch (e) {
      results.add(EvalRow(truth: truth, error: e.toString()));
      stdout.writeln('    -> LỖI: $e');
    }
    // Nghỉ 4 giây giữa các mẫu để không chạm giới hạn Rate Limit (5-15 RPM của Gemini Free Tier)
    await Future.delayed(const Duration(seconds: 4));
  }

  final outDir = Directory('${baseDir.path}/out')..createSync(recursive: true);
  File('${outDir.path}/results.csv').writeAsStringSync(_toCsv(results));
  final summary = _buildSummary(results);
  File('${outDir.path}/results.md').writeAsStringSync(summary);

  stdout.writeln('\n===== TỔNG KẾT =====');
  stdout.writeln(summary);
  stdout.writeln('\nĐã ghi: ${outDir.path}/results.csv và ${outDir.path}/results.md');
}

Future<Prediction> _predictWithRetry(
  GenerativeModel model,
  GroundTruthRow row, {
  int maxRetries = 3,
}) async {
  for (var attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await _predict(model, row);
    } catch (e) {
      final msg = e.toString();
      final isRateLimit = msg.contains('429') ||
          msg.contains('503') ||
          msg.contains('Quota exceeded');
      if (isRateLimit && attempt < maxRetries) {
        final waitSec = 10 * attempt;
        stdout.writeln(
          '    [Rate Limit/Busy] Chờ $waitSec giây rồi thử lại (lần $attempt/$maxRetries)...',
        );
        await Future.delayed(Duration(seconds: waitSec));
        continue;
      }
      rethrow;
    }
  }
  throw const SocketException('Thử lại vượt quá số lần cho phép.');
}

Future<Prediction> _predict(GenerativeModel model, GroundTruthRow row) async {
  final List<Part> parts;
  if (row.imagePath.isNotEmpty && File(row.imagePath).existsSync()) {
    final bytes = await File(row.imagePath).readAsBytes();
    final mime = _mimeType(row.imagePath);
    parts = [TextPart(_systemInstruction), DataPart(mime, bytes)];
  } else {
    parts = [TextPart('$_systemInstruction\n\nPhân tích dinh dưỡng món ăn: "${row.foodName}"')];
  }

  final response = await model.generateContent([Content.multi(parts)]);
  final text = response.text;
  if (text == null || text.trim().isEmpty) {
    throw const FormatException('Không nhận được phản hồi từ AI.');
  }
  final clean = text.replaceAll(RegExp(r'^```json|```$'), '').trim();
  final json = jsonDecode(clean) as Map<String, dynamic>;
  return Prediction(
    isFood: json['is_food'] as bool? ?? false,
    foodName: json['food_name']?.toString() ?? '',
    calories: (json['calories'] as num?)?.toDouble() ?? 0,
    proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
    fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
    carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
  );
}

String _buildSummary(List<EvalRow> results) {
  final total = results.length;
  final errors = results.where((r) => r.prediction == null).length;
  final valid = results.where((r) => r.prediction != null).toList();
  final matched = results.where((r) => r.nameMatched).length;

  final nameAccuracy = total == 0 ? 0.0 : matched / total * 100;

  final calMae = _mae(valid, (r) => r.truth.calories, (r) => r.prediction!.calories);
  final calMape = _mape(valid, (r) => r.truth.calories, (r) => r.prediction!.calories);
  final within20 =
      valid.isEmpty
          ? 0.0
          : valid
                  .where((r) =>
                      r.truth.calories > 0 &&
                      ((r.prediction!.calories - r.truth.calories).abs() /
                              r.truth.calories) <=
                          0.2)
                  .length /
              valid.length *
              100;
  final proteinMae = _mae(valid, (r) => r.truth.proteinG, (r) => r.prediction!.proteinG);
  final fatMae = _mae(valid, (r) => r.truth.fatG, (r) => r.prediction!.fatG);
  final carbsMae = _mae(valid, (r) => r.truth.carbsG, (r) => r.prediction!.carbsG);

  final b = StringBuffer()
    ..writeln('# Kết quả đánh giá Food Scan (Gemini $_modelName)')
    ..writeln()
    ..writeln('- Tổng số mẫu: **$total**')
    ..writeln('- Số mẫu lỗi/không phản hồi: **$errors**')
    ..writeln()
    ..writeln('## Chỉ số chính')
    ..writeln()
    ..writeln('| Chỉ số | Giá trị |')
    ..writeln('|---|---|')
    ..writeln('| Accuracy nhận diện tên món | ${nameAccuracy.toStringAsFixed(1)}% |')
    ..writeln('| MAE calories | ${calMae.toStringAsFixed(1)} kcal |')
    ..writeln('| MAPE calories | ${calMape.toStringAsFixed(1)}% |')
    ..writeln('| Tỉ lệ calories lệch trong ±20% | ${within20.toStringAsFixed(1)}% |')
    ..writeln('| MAE protein | ${proteinMae.toStringAsFixed(1)} g |')
    ..writeln('| MAE fat | ${fatMae.toStringAsFixed(1)} g |')
    ..writeln('| MAE carbs | ${carbsMae.toStringAsFixed(1)} g |')
    ..writeln()
    ..writeln('## Chi tiết theo món')
    ..writeln()
    ..writeln(
      '| # | Món (đáp án) | Món (AI đoán) | Đúng tên | Kcal đáp án | Kcal AI | Lệch |',
    )
    ..writeln('|---|---|---|---|---|---|---|');

  for (final r in results) {
    final p = r.prediction;
    if (p == null) {
      b.writeln('| ${r.truth.id} | ${r.truth.foodName} | — | — | ${r.truth.calories} | LỖI | — |');
      continue;
    }
    final diff = p.calories - r.truth.calories;
    b.writeln(
      '| ${r.truth.id} | ${r.truth.foodName} | ${p.foodName} | '
      '${r.nameMatched ? "✓" : "✗"} | ${r.truth.calories.toStringAsFixed(0)} | '
      '${p.calories.toStringAsFixed(0)} | ${diff >= 0 ? "+" : ""}${diff.toStringAsFixed(0)} |',
    );
  }

  return b.toString();
}

double _mae(
  List<EvalRow> rows,
  double Function(EvalRow) exp,
  double Function(EvalRow) pred,
) {
  if (rows.isEmpty) return 0;
  var sum = 0.0;
  for (final r in rows) {
    sum += (pred(r) - exp(r)).abs();
  }
  return sum / rows.length;
}

double _mape(
  List<EvalRow> rows,
  double Function(EvalRow) exp,
  double Function(EvalRow) pred,
) {
  final valid = rows.where((r) => exp(r) > 0).toList();
  if (valid.isEmpty) return 0;
  var sum = 0.0;
  for (final r in valid) {
    sum += (pred(r) - exp(r)).abs() / exp(r);
  }
  return sum / valid.length * 100;
}

String _toCsv(List<EvalRow> results) {
  final b = StringBuffer()
    ..writeln(
      'id,food_name_expected,is_food,food_name_predicted,name_matched,'
      'calories_expected,calories_predicted,calories_abs_err,'
      'protein_expected,protein_predicted,protein_abs_err,'
      'fat_expected,fat_predicted,fat_abs_err,'
      'carbs_expected,carbs_predicted,carbs_abs_err,error',
    );
  for (final r in results) {
    final p = r.prediction;
    if (p == null) {
      b.writeln(
        '${r.truth.id},${_csv(r.truth.foodName)},,,,,,,,,,,,,,,,${_csv(r.error ?? "")}',
      );
      continue;
    }
    b.writeln([
      r.truth.id,
      _csv(r.truth.foodName),
      p.isFood,
      _csv(p.foodName),
      r.nameMatched,
      r.truth.calories,
      p.calories,
      (p.calories - r.truth.calories).abs(),
      r.truth.proteinG,
      p.proteinG,
      (p.proteinG - r.truth.proteinG).abs(),
      r.truth.fatG,
      p.fatG,
      (p.fatG - r.truth.fatG).abs(),
      r.truth.carbsG,
      p.carbsG,
      (p.carbsG - r.truth.carbsG).abs(),
      '',
    ].join(','));
  }
  return b.toString();
}

String? _resolveApiKey(List<String> args) {
  for (final a in args) {
    if (a.startsWith('--api-key=')) return a.substring('--api-key='.length);
  }
  return Platform.environment['GEMINI_API_KEY'];
}

String _mimeType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}

List<GroundTruthRow> _parseGroundTruth(String content) {
  final rows = _parseCsv(content);
  if (rows.isEmpty) return const [];
  final result = <GroundTruthRow>[];
  for (var i = 1; i < rows.length; i++) {
    final c = rows[i];
    if (c.length < 6) continue;
    if (c[0].trim().isEmpty && c[1].trim().isEmpty) continue;
    result.add(GroundTruthRow(
      id: c[0].trim(),
      foodName: c[1].trim(),
      calories: double.tryParse(c[2].trim()) ?? 0,
      proteinG: double.tryParse(c[3].trim()) ?? 0,
      fatG: double.tryParse(c[4].trim()) ?? 0,
      carbsG: double.tryParse(c[5].trim()) ?? 0,
      imagePath: c.length > 6 ? c[6].trim() : '',
    ));
  }
  return result;
}

List<List<String>> _parseCsv(String input) {
  final rows = <List<String>>[];
  var fields = <String>[];
  final sb = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          sb.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        sb.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      fields.add(sb.toString());
      sb.clear();
    } else if (c == '\n') {
      fields.add(sb.toString());
      sb.clear();
      rows.add(List.of(fields));
      fields = <String>[];
    } else if (c != '\r') {
      sb.write(c);
    }
  }
  if (sb.isNotEmpty || fields.isNotEmpty) {
    fields.add(sb.toString());
    rows.add(List.of(fields));
  }
  return rows.where((r) => r.any((f) => f.trim().isNotEmpty)).toList();
}

String _csv(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

bool _nameMatches(String expected, String predicted) {
  final e = _normalize(expected);
  final p = _normalize(predicted);
  if (e.isEmpty || p.isEmpty) return false;
  if (e == p) return true;
  if (p.contains(e) || e.contains(p)) return true;
  return _similarity(e, p) >= 0.6;
}

String _normalize(String s) {
  var t = _removeDiacritics(s.toLowerCase());
  t = t.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t;
}

double _similarity(String a, String b) {
  if (a == b) return 1;
  if (a.isEmpty || b.isEmpty) return 0;
  final aBigrams = _bigrams(a);
  final bBigrams = _bigrams(b);
  if (aBigrams.isEmpty || bBigrams.isEmpty) return 0;
  final remaining = List.of(bBigrams);
  var inter = 0;
  for (final g in aBigrams) {
    if (remaining.remove(g)) inter++;
  }
  return (2 * inter) / (aBigrams.length + bBigrams.length);
}

List<String> _bigrams(String s) {
  if (s.length < 2) return [s];
  return [for (var i = 0; i < s.length - 1; i++) s.substring(i, i + 2)];
}

const Map<String, String> _diacritics = {
  'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
  'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
  'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
  'đ': 'd',
  'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
  'ê': 'e', 'ề': 'e', 'ế': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
  'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
  'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
  'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
  'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
  'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
  'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
  'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
};

String _removeDiacritics(String s) {
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(_diacritics[ch] ?? ch);
  }
  return b.toString();
}
