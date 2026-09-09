import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_analysis.dart';

class FoodAiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = 'gemini-3.8-flash';

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<FoodAnalysis> analyze(Uint8List bytes, {String mimeType = 'image/jpeg'}) async {
    if (!isConfigured) {
      throw StateError('Chưa cấu hình GEMINI_API_KEY.');
    }

    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent');
    final prompt = '''
Bạn là chuyên gia ước tính dinh dưỡng từ ảnh món ăn. Hãy nhận diện mọi món có thể thấy, ước tính khẩu phần thực tế và calories/macros. Không được giả vờ chính xác nếu ảnh thiếu thông tin.

Chỉ trả về JSON hợp lệ, KHÔNG markdown, theo schema:
{
  "dish_name": "tên bữa ăn ngắn gọn bằng tiếng Việt",
  "total_calories": 0,
  "protein_g": 0,
  "carbs_g": 0,
  "fat_g": 0,
  "confidence": "low|medium|high",
  "note": "ghi chú ngắn về phần nào khó ước lượng",
  "items": [
    {"name":"...","portion":"...","calories":0,"protein_g":0,"carbs_g":0,"fat_g":0}
  ]
}

Calories là ước tính trung tâm hợp lý, không phải khoảng. Nếu không chắc lượng dầu/sốt/cơm, nêu rõ trong note.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'inline_data': {'mime_type': mimeType, 'data': base64Encode(bytes)}},
            {'text': prompt},
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.2,
      }
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': _apiKey},
      body: body,
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI trả về lỗi ${response.statusCode}: ${response.body}');
    }

    final root = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = root['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) throw Exception('AI không trả về kết quả.');
    final content = (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;
    final text = parts?.whereType<Map>().map((p) => p['text']?.toString()).firstWhere((t) => t != null && t.isNotEmpty, orElse: () => null);
    if (text == null) throw Exception('Không đọc được kết quả AI.');

    var clean = text.trim();
    if (clean.startsWith('```')) {
      clean = clean.replaceFirst(RegExp(r'^```(?:json)?\s*'), '').replaceFirst(RegExp(r'\s*```$'), '');
    }
    return FoodAnalysis.fromJson(jsonDecode(clean) as Map<String, dynamic>);
  }
}
