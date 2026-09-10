import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_analysis.dart';

class FoodAiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // 2.5 Flash is a stable multimodal model and is enough for food-photo analysis.
  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-3.8-flash',
  ];

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<FoodAnalysis> analyze(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (!isConfigured) {
      throw StateError(
        'AI chưa được kích hoạt. GEMINI_API_KEY chưa có trong APK.',
      );
    }

    if (bytes.isEmpty) {
      throw const FormatException('Ảnh trống hoặc không đọc được.');
    }

    if (bytes.lengthInBytes > 15 * 1024 * 1024) {
      throw const FormatException('Ảnh quá lớn. Hãy dùng ảnh nhỏ hơn 15 MB.');
    }

    if (mimeType == 'image/heic' || mimeType == 'image/heif') {
      throw const FormatException(
        'Ảnh HEIC/HEIF chưa được hỗ trợ tốt. Hãy chụp bằng camera trong app hoặc chọn ảnh JPG/PNG.',
      );
    }

    await _ensureInternet();

    final base64Data = base64Encode(bytes);
    Object? lastError;

    for (final model in _models) {
      try {
        final json = await _callGenerateContent(
          model: model,
          base64Data: base64Data,
          mimeType: mimeType,
        );
        return FoodAnalysis.fromJson(json);
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception(
      'Không thể phân tích ảnh sau khi thử các model AI. ${lastError ?? ''}',
    );
  }

  Future<void> _ensureInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'generativelanguage.googleapis.com',
      ).timeout(const Duration(seconds: 8));

      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        throw SocketException('Không tìm thấy máy chủ AI.');
      }
    } on SocketException {
      throw SocketException(
        'Điện thoại chưa có kết nối Internet. Hãy bật Wi-Fi hoặc 4G/5G rồi thử lại.',
      );
    } on TimeoutException {
      throw SocketException(
        'Kiểm tra Internet bị quá thời gian. Hãy kiểm tra mạng rồi thử lại.',
      );
    }
  }

  Future<Map<String, dynamic>> _callGenerateContent({
    required String model,
    required String base64Data,
    required String mimeType,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );

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
        'temperature': 0.1,
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
    final text = _extractGeneratedText(root);

    if (text == null || text.trim().isEmpty) {
      throw const FormatException('Gemini không trả về nội dung phân tích.');
    }

    return _parseJsonText(text);
  }

  void _throwIfBadStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String serverMessage = response.body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        serverMessage = decoded['error']['message']?.toString() ?? serverMessage;
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        throw Exception('Gemini từ chối request: $serverMessage');
      case 401:
      case 403:
        throw Exception(
          'API key Gemini không hợp lệ hoặc chưa được cấp quyền: $serverMessage',
        );
      case 404:
        throw Exception('Model Gemini không khả dụng: $serverMessage');
      case 429:
        throw Exception(
          'Gemini đã hết quota/tạm giới hạn request. Hãy thử lại sau: $serverMessage',
        );
      default:
        if (response.statusCode >= 500) {
          throw Exception('Máy chủ Gemini đang lỗi tạm thời: $serverMessage');
        }
        throw Exception('Gemini lỗi ${response.statusCode}: $serverMessage');
    }
  }

  String? _extractGeneratedText(dynamic root) {
    if (root is! Map<String, dynamic>) return null;
    final candidates = root['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final first = candidates.first;
    if (first is! Map) return null;

    final content = first['content'];
    if (content is! Map) return null;

    final parts = content['parts'];
    if (parts is! List) return null;

    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        final text = part['text'] as String;
        if (text.trim().isNotEmpty) return text;
      }
    }
    return null;
  }

  Map<String, dynamic> _parseJsonText(String text) {
    var clean = text.trim();

    if (clean.startsWith('```')) {
      clean = clean.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      clean = clean.replaceFirst(RegExp(r'\s*```$'), '');
    }

    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start >= 0 && end > start) {
      clean = clean.substring(start, end + 1);
    }

    final decoded = jsonDecode(clean);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Kết quả AI không đúng định dạng JSON.');
    }
    return decoded;
  }

  static const String _prompt = '''
Phân tích bữa ăn trong ảnh và ước tính dinh dưỡng.

Yêu cầu:
- Nhận diện tất cả món ăn nhìn thấy rõ.
- Ước tính khẩu phần hợp lý từ hình ảnh.
- Ước tính tổng calories, protein, carbs và fat.
- Nếu không chắc lượng dầu, sốt, đường hoặc khối lượng, hãy ghi rõ trong note.
- Không tuyên bố độ chính xác tuyệt đối.
- Trả lời bằng tiếng Việt.

CHỈ trả về JSON hợp lệ theo đúng cấu trúc sau, không thêm markdown:
{
  "dish_name": "Tên bữa ăn",
  "total_calories": 0,
  "protein_g": 0,
  "carbs_g": 0,
  "fat_g": 0,
  "confidence": "low|medium|high",
  "note": "Ghi chú ngắn",
  "items": [
    {
      "name": "Tên món",
      "portion": "Khẩu phần ước tính",
      "calories": 0,
      "protein_g": 0,
      "carbs_g": 0,
      "fat_g": 0
    }
  ]
}
''';
}
