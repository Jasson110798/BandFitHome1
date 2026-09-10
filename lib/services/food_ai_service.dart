import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_analysis.dart';

class FoodAiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const _preferredModel = 'gemini-2.5-flash';
  static const _fallbackModel = 'gemini-3.8-flash';

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<FoodAnalysis> analyze(Uint8List bytes, {String mimeType = 'image/jpeg'}) async {
    if (!isConfigured) {
      throw StateError('AI chưa được kích hoạt. Hãy thêm GEMINI_API_KEY và build lại APK.');
    }
    if (bytes.isEmpty) {
      throw const FormatException('Ảnh trống hoặc không đọc được dữ liệu ảnh.');
    }
    if (bytes.lengthInBytes > 15 * 1024 * 1024) {
      throw const FormatException('Ảnh quá lớn. Hãy chụp hoặc chọn ảnh nhỏ hơn 15MB.');
    }

    final base64Data = base64Encode(bytes);

    try {
      final text = await _callInteractions(
        model: _preferredModel,
        base64Data: base64Data,
        mimeType: mimeType,
      );
      return FoodAnalysis.fromJson(_parseJsonText(text));
    } catch (_) {
      try {
        final text = await _callInteractions(
          model: _fallbackModel,
          base64Data: base64Data,
          mimeType: mimeType,
        );
        return FoodAnalysis.fromJson(_parseJsonText(text));
      } catch (_) {
        final text = await _callLegacyGenerateContent(
          model: _preferredModel,
          base64Data: base64Data,
          mimeType: mimeType,
        );
        return FoodAnalysis.fromJson(_parseJsonText(text));
      }
    }
  }

  Future<String> _callInteractions({
    required String model,
    required String base64Data,
    required String mimeType,
  }) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/interactions');
    final body = jsonEncode({
      'model': model,
      'input': [
        {
          'type': 'text',
          'text': _prompt,
        },
        {
          'type': 'image',
          'data': base64Data,
          'mime_type': mimeType,
        }
      ]
    });

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 60));

    _throwIfBadStatus(response);
    final root = jsonDecode(response.body);
    final text = _extractText(root);
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('AI không trả về nội dung phân tích được.');
    }
    return text;
  }

  Future<String> _callLegacyGenerateContent({
    required String model,
    required String base64Data,
    required String mimeType,
  }) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Data,
              }
            },
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      }
    });

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 60));

    _throwIfBadStatus(response);
    final root = jsonDecode(response.body);
    final text = _extractText(root);
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('AI không trả về nội dung phân tích được.');
    }
    return text;
  }

  void _throwIfBadStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final body = response.body;
    if (response.statusCode == 400) {
      throw Exception('Yêu cầu AI không hợp lệ. Hãy thử chụp ảnh rõ hơn hoặc build lại bản vá mới.\n\n$body');
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('API key Gemini không hợp lệ hoặc chưa được phép dùng model này. Hãy kiểm tra GEMINI_API_KEY rồi build lại APK.\n\n$body');
    }
    if (response.statusCode == 404) {
      throw Exception('Không tìm thấy endpoint/model AI. Bản vá này sẽ cần build lại với workflow mới.\n\n$body');
    }
    if (response.statusCode == 429) {
      throw Exception('Bạn đã vượt giới hạn request của Gemini. Hãy chờ một lúc rồi thử lại.\n\n$body');
    }
    if (response.statusCode >= 500) {
      throw Exception('Máy chủ AI của Google đang lỗi tạm thời. Hãy thử lại sau vài phút.\n\n$body');
    }
    throw Exception('AI trả về lỗi ${response.statusCode}.\n\n$body');
  }

  Map<String, dynamic> _parseJsonText(String text) {
    var clean = text.trim();
    if (clean.startsWith('```')) {
      clean = clean.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      clean = clean.replaceFirst(RegExp(r'\s*```$'), '');
    }

    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      clean = clean.substring(start, end + 1);
    }

    final decoded = jsonDecode(clean);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Kết quả AI không đúng định dạng JSON đối tượng.');
    }
    return decoded;
  }

  String? _extractText(dynamic root) {
    if (root is Map<String, dynamic>) {
      for (final key in ['output_text', 'outputText', 'text']) {
        final value = root[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }

      final interaction = root['interaction'];
      final fromInteraction = _extractText(interaction);
      if (fromInteraction != null) return fromInteraction;

      final output = root['output'];
      final fromOutput = _extractText(output);
      if (fromOutput != null) return fromOutput;

      final candidates = root['candidates'];
      final fromCandidates = _extractText(candidates);
      if (fromCandidates != null) return fromCandidates;

      final content = root['content'];
      final fromContent = _extractText(content);
      if (fromContent != null) return fromContent;

      final parts = root['parts'];
      final fromParts = _extractText(parts);
      if (fromParts != null) return fromParts;
    }

    if (root is List) {
      for (final item in root) {
        final text = _extractText(item);
        if (text != null && text.trim().isNotEmpty) return text;
      }
    }

    return null;
  }

  static const String _prompt = '''
Bạn là chuyên gia phân tích dinh dưỡng từ ảnh món ăn.

Nhiệm vụ:
- Nhận diện món hoặc bữa ăn trong ảnh.
- Ước tính khẩu phần thực tế hợp lý.
- Ước tính tổng calories, protein, carbs, fat.
- Nếu ảnh thiếu thông tin, hãy nêu rõ trong note.
- Không được bịa chính xác tuyệt đối.

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
''';
}
