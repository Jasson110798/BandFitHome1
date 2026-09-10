import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_analysis.dart';
import '../services/food_ai_service.dart';

class FoodAiScreen extends StatefulWidget {
  const FoodAiScreen({super.key});

  @override
  State<FoodAiScreen> createState() => _FoodAiScreenState();
}

class _FoodAiScreenState extends State<FoodAiScreen> {
  final _picker = ImagePicker();
  final _service = FoodAiService();
  XFile? _image;
  FoodAnalysis? _result;
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 78,
        maxWidth: 1440,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file == null) return;
      setState(() {
        _image = file;
        _result = null;
        _error = null;
      });
      await _analyze();
    } on PlatformException catch (e) {
      setState(() => _error = _friendlyPlatformError(e));
    } on Exception catch (e) {
      setState(() => _error = 'Không thể mở camera/thư viện. ${e.toString()}');
    }
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null || _loading) return;
    if (!_service.isConfigured) {
      setState(() => _error = 'AI chưa được kích hoạt. Hãy kiểm tra GEMINI_API_KEY, workflow build và cài lại APK mới.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bytes = await image.readAsBytes();
      final mime = _guessMimeType(image.path);
      final result = await _service.analyze(bytes, mimeType: mime);
      if (!mounted) return;
      setState(() => _result = result);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = 'AI phản hồi quá chậm. Hãy kiểm tra mạng rồi thử lại.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyServiceError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _guessMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) return 'image/png';
    if (ext.endsWith('.webp')) return 'image/webp';
    if (ext.endsWith('.heic') || ext.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  String _friendlyPlatformError(PlatformException e) {
    final code = e.code.toLowerCase();
    if (code.contains('camera_access_denied') || code.contains('photo_access_denied')) {
      return 'Bạn đã từ chối quyền camera hoặc thư viện ảnh. Vào Cài đặt > Ứng dụng > BandFit Home > Quyền và bật lại quyền cần thiết.';
    }
    if (code.contains('camera_access_restricted') || code.contains('photo_access_restricted')) {
      return 'Thiết bị đang chặn quyền camera/thư viện. Hãy kiểm tra cài đặt quyền hoặc thử ảnh từ thư viện.';
    }
    if (code.contains('no_available_camera')) {
      return 'Không tìm thấy camera trên thiết bị. Hãy thử chọn ảnh từ thư viện.';
    }
    return 'Không thể mở camera/thư viện (${e.code}). ${e.message ?? ''}'.trim();
  }

  String _friendlyServiceError(Object error) {
    final text = error.toString();
    if (text.contains('401') || text.contains('403') || text.contains('API key')) {
      return 'API Gemini chưa đúng hoặc chưa được đưa vào APK. Hãy build lại bản vá mới rồi cài lại app.';
    }
    if (text.contains('429')) {
      return 'Gemini đang hết quota tạm thời. Hãy đợi một chút rồi thử lại.';
    }
    if (text.contains('SocketException') || text.contains('Failed host lookup')) {
      return 'Không kết nối được internet. Hãy kiểm tra Wi‑Fi/4G rồi thử lại.';
    }
    return 'AI chưa phân tích được ảnh này. Hãy thử ảnh sáng hơn, chỉ có 1 bữa ăn rõ ràng, hoặc dùng ảnh từ thư viện.\n\n$text';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Text(
              'AI Calo',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Chụp món ăn hoặc chọn ảnh có sẵn để AI ước tính calories và macro.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(26),
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mẹo để nhận diện tốt hơn: đặt món ăn ở nơi đủ sáng, chụp gần vừa phải, tránh quá nhiều món chồng lên nhau. Kết quả chỉ là ước tính.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 64),
                    SizedBox(height: 12),
                    Text('Chưa có ảnh món ăn', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp ảnh'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Thư viện'),
                  ),
                ),
              ],
            ),
            if (_image != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loading ? null : _analyze,
                icon: const Icon(Icons.refresh),
                label: const Text('Phân tích lại ảnh này'),
              ),
            ],
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              const Center(child: Text('AI đang nhận diện món và ước tính khẩu phần…')),
            ],
            if (_error != null) ...[
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_error!)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nếu vẫn lỗi, hãy thử:\n• dùng ảnh từ thư viện\n• chụp sáng hơn\n• cài lại APK mới nhất\n• kiểm tra 4G/Wi‑Fi',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 22),
              _ResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final FoodAnalysis result;
  const _ResultCard({required this.result});

  Color _confidenceColor(BuildContext context) {
    switch (result.confidence.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'low':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                result.dishName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _confidenceColor(context).withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Tin cậy: ${result.confidence}',
                style: TextStyle(
                  color: _confidenceColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                '${result.totalCalories}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Text('kcal ước tính'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Macro('Protein', result.protein),
                  _Macro('Carb', result.carbs),
                  _Macro('Fat', result.fat),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...result.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${item.portion} • P ${item.protein.toStringAsFixed(0)}g • C ${item.carbs.toStringAsFixed(0)}g • F ${item.fat.toStringAsFixed(0)}g',
                ),
                trailing: Text('${item.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
        if (result.note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Lưu ý: ${result.note}', style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final double value;
  const _Macro(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(0)}g',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        Text(label),
      ],
    );
  }
}
