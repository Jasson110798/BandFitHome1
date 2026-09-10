import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_analysis.dart';

class AiDiagnostic {
  final bool ok;
  final String title;
  final String detail;
  final String? model;
  final int? statusCode;

  const AiDiagnostic({
    required this.ok,
    required this.title,
    required this.detail,
    this.model,
    this.statusCode,
  });
}

class FoodAiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  String? _cachedModel;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<AiDiagnostic> diagnose() async {
    if (!isConfigured) {
      return const AiDiagnostic(
        ok: false,
        title: 'Thiếu API key',
        detail: 'GEMINI_API_KEY chưa được nhúng vào APK. Hãy kiểm tra GitHub Secret và build lại.',
      );
    }

    try {
      await _ensureInternet();
    } catch (e) {
      return AiDiagnostic(
        ok: false,
        title: 'Không có Internet',
        detail: e.toString(),
      );
    }

    try {
      final model = await _discoverModel(force: true);
      final ping = await _textPing(model);
      return AiDiagnostic(
        ok: true,
        title: 'AI hoạt động',
        detail: 'Kết nối Gemini thành công. Phản hồi kiểm tra: $ping',
        model: model,
        statusCode: 200,
      );
    } on AiHttpException catch (e) {
      return AiDiagnostic(
        ok: false,
        title: _titleForStatus(e.statusCode),
        detail: e.message,
        statusCode: e.statusCode,
      );
    } catch (e) {
      return AiDiagnostic(
        ok: false,
        title: 'Lỗi kiểm tra AI',
        detail: e.toString(),
      );
    }
  }

  Future<FoodAnalysis> analyze(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (!isConfigured) {
      throw StateError('GEMINI_API_KEY chưa có trong APK.');
    }
    if (bytes.isEmpty) {
      throw const FormatException('Ảnh trống hoặc không đọc được dữ liệu ảnh.');
    }
    if (bytes.lengthInBytes > 15 * 1024 * 1024) {
      throw const FormatException('Ảnh quá lớn. Hãy dùng ảnh nhỏ hơn 15MB.');
    }

    await _ensureInternet();
    final model = await _discoverModel();
    final base64Data = base64Encode(bytes);

    final root = await _generateContent(
      model: model,
      parts: [
        {'text': _foodPrompt},
        {
          'inline_data': {
            'mime_type': mimeType,
            'data': base64Data,
          }
        },
      ],
      temperature: 0.1,
    );

    final text = _extractGeneratedText(root);
    if (text == null || text.trim().isEmpty) {
      final blockReason = _extractBlockReason(root);
      throw FormatException(
        blockReason == null
            ? 'Gemini trả về phản hồi nhưng không có nội dung văn bản.'
            : 'Gemini chặn phản hồi: $blockReason',
      );
    }

    return FoodAnalysis.fromJson(_parseJsonText(text));
  }

  Future<void> _ensureInternet() async {
    try {
      final result = await InternetAddress.lookup('generativelanguage.googleapis.com')
          .timeout(const Duration(seconds: 8));
      if (result.isEmpty || result.first.rawAddress.isEmpty) {
        throw SocketException('Không tìm thấy máy chủ Gemini.');
      }
    } on TimeoutException {
      throw SocketException('Kết nối Internet quá chậm hoặc bị chặn.');
    } on SocketException catch (e) {
      throw SocketException('Không kết nối được Internet/Gemini: ${e.message}');
    }
  }

  Future<String> _discoverModel({bool force = false}) async {
    if (!force && _cachedModel != null) return _cachedModel!;

    final uri = Uri.parse('$_base/models?pageSize=1000');
    final response = await http
        .get(uri, headers: {'x-goog-api-key': _apiKey})
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiHttpException(response.statusCode, _serverMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Danh sách model Gemini không đúng định dạng.');
    }

    final models = (decoded['models'] as List?)?.whereType<Map>().toList() ?? const [];
    final available = <String>[];

    for (final raw in models) {
      final methods = (raw['supportedGenerationMethods'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[];
      if (!methods.contains('generateContent')) continue;

      final rawName = raw['name']?.toString() ?? '';
      final name = rawName.startsWith('models/') ? rawName.substring(7) : rawName;
      if (name.isNotEmpty) available.add(name);
    }

    if (available.isEmpty) {
      throw const FormatException('API key không có model nào hỗ trợ generateContent.');
    }

    const preferred = [
      'gemini-3.8-flash',
      'gemini-3.7-flash',
      'gemini-3.6-flash',
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite',
    ];

    for (final wanted in preferred) {
      if (available.contains(wanted)) {
        _cachedModel = wanted;
        return wanted;
      }
    }

    final flash = available.firstWhere(
      (m) => m.contains('flash') && !m.contains('image') && !m.contains('tts') && !m.contains('live'),
      orElse: () => available.first,
    );
    _cachedModel = flash;
    return flash;
  }

  Future<String> _textPing(String model) async {
    final root = await _generateContent(
      model: model,
      parts: const [
        {'text': 'Trả lời đúng một từ: OK'}
      ],
      temperature: 0,
    );
    return (_extractGeneratedText(root) ?? 'Không có text').trim();
  }

  Future<Map<String, dynamic>> _generateContent({
    required String model,
    required List<Map<String, dynamic>> parts,
    required num temperature,
  }) async {
    final uri = Uri.parse('$_base/models/$model:generateContent');
    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': parts,
        }
      ],
      'generationConfig': {
        'temperature': temperature,
      },
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiHttpException(response.statusCode, _serverMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Gemini trả về dữ liệu không đúng định dạng.');
    }
    return decoded;
  }

  String _serverMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        final message = error['message']?.toString();
        final status = error['status']?.toString();
        if (message != null) {
          return '${status == null ? '' : '$status: '}$message';
        }
      }
    } catch (_) {}
    return response.body.isEmpty ? 'HTTP ${response.statusCode}' : response.body;
  }

  String? _extractGeneratedText(Map<String, dynamic> root) {
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

  String? _extractBlockReason(Map<String, dynamic> root) {
    final promptFeedback = root['promptFeedback'];
    if (promptFeedback is Map && promptFeedback['blockReason'] != null) {
      return promptFeedback['blockReason'].toString();
    }
    final candidates = root['candidates'];
    if (candidates is List && candidates.isNotEmpty && candidates.first is Map) {
      final finish = (candidates.first as Map)['finishReason'];
      if (finish != null && finish.toString() != 'STOP') return finish.toString();
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
    if (start >= 0 && end > start) clean = clean.substring(start, end + 1);

    final decoded = jsonDecode(clean);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('AI trả về JSON không đúng cấu trúc.');
    }
    return decoded;
  }

  String _titleForStatus(int code) {
    switch (code) {
      case 400:
        return 'Request không hợp lệ';
      case 401:
      case 403:
        return 'API key bị từ chối';
      case 404:
        return 'Model/endpoint không tồn tại';
      case 429:
        return 'Hết quota Gemini';
      default:
        if (code >= 500) return 'Máy chủ Gemini đang lỗi';
        return 'Gemini trả lỗi HTTP $code';
    }
  }

  static const String _foodPrompt = '''
Bạn là công cụ ước tính dinh dưỡng từ ảnh món ăn.

Hãy:
- nhận diện các món nhìn thấy rõ,
- ước tính khẩu phần hợp lý,
- ước tính calories, protein, carbs và fat,
- nêu rõ điều gì khó ước tính (dầu, sốt, đường, khối lượng...),
- trả lời bằng tiếng Việt,
- không tuyên bố độ chính xác tuyệt đối.

CHỈ trả về JSON hợp lệ theo cấu trúc:
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

class AiHttpException implements Exception {
  final int statusCode;
  final String message;
  const AiHttpException(this.statusCode, this.message);

  @override
  String toString() => 'HTTP $statusCode: $message';
}
