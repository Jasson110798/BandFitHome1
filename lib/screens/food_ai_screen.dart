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
  AiDiagnostic? _diagnostic;
  bool _loading = false;
  bool _testing = false;
  String? _error;
  String? _technicalError;

  Future<void> _testAi() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _diagnostic = null;
      _error = null;
      _technicalError = null;
    });

    final diagnostic = await _service.diagnose();
    if (!mounted) return;
    setState(() {
      _diagnostic = diagnostic;
      _testing = false;
    });
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file == null) return;
      setState(() {
        _image = file;
        _result = null;
        _error = null;
        _technicalError = null;
      });
    } on PlatformException catch (e) {
      setState(() {
        _error = _friendlyPlatformError(e);
        _technicalError = '${e.code}: ${e.message ?? ''}';
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể mở camera/thư viện.';
        _technicalError = e.toString();
      });
    }
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null || _loading) return;

    if (!_service.isConfigured) {
      setState(() {
        _error = 'APK hiện tại chưa có GEMINI_API_KEY.';
        _technicalError = 'String.fromEnvironment(GEMINI_API_KEY) đang rỗng.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
      _technicalError = null;
    });

    try {
      final bytes = await image.readAsBytes();
      final mime = _guessMimeType(image.path);
      final result = await _service.analyze(bytes, mimeType: mime);
      if (!mounted) return;
      setState(() => _result = result);
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'AI phản hồi quá chậm. Hãy kiểm tra mạng rồi thử lại.';
        _technicalError = e.toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyServiceError(e);
        _technicalError = e.toString();
      });
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
      return 'Bạn đã từ chối quyền camera hoặc thư viện ảnh. Vào Cài đặt > Ứng dụng > BandFit Home > Quyền và bật lại.';
    }
    if (code.contains('no_available_camera')) {
      return 'Không tìm thấy camera. Hãy dùng ảnh từ thư viện.';
    }
    return 'Không thể mở camera/thư viện.';
  }

  String _friendlyServiceError(Object error) {
    final text = error.toString();
    if (text.contains('HTTP 401') || text.contains('HTTP 403')) {
      return 'Google đang từ chối API key. Hãy bấm “Kiểm tra AI” để xem nguyên nhân.';
    }
    if (text.contains('HTTP 429')) {
      return 'Gemini đang hết quota hoặc bị giới hạn request. Hãy bấm “Kiểm tra AI” để xác nhận.';
    }
    if (text.contains('SocketException')) {
      return 'Không kết nối được Gemini qua Internet.';
    }
    if (text.contains('HEIC') || text.contains('HEIF')) {
      return 'Ảnh HEIC/HEIF gây lỗi. Hãy thử chụp bằng camera trong app hoặc dùng ảnh JPG/PNG.';
    }
    return 'AI nhận được ảnh nhưng quá trình phân tích thất bại. Xem “Chi tiết kỹ thuật” bên dưới.';
  }

  Future<void> _copyTechnical() async {
    final text = _technicalError;
    if (text == null || text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép chi tiết lỗi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Calo',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      const Text('Chụp món ăn → AI nhận diện → ước tính calories và macro.'),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _testing ? null : _testAi,
                  icon: _testing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.health_and_safety_outlined),
                  label: const Text('Kiểm tra AI'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_diagnostic != null) _DiagnosticCard(diagnostic: _diagnostic!),
            if (_diagnostic != null) const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ảnh rõ, đủ sáng và chỉ có một bữa ăn sẽ cho kết quả tốt hơn. Kết quả calories chỉ là ước tính.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_image == null)
              Container(
                height: 235,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 64),
                    SizedBox(height: 10),
                    Text('Chưa có ảnh món ăn', style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(File(_image!.path), fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 12),
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
              FilledButton.icon(
                onPressed: _loading ? null : _analyze,
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_loading ? 'Đang phân tích…' : 'Phân tích ảnh'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
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
                          Expanded(child: Text(_error!, style: const TextStyle(fontWeight: FontWeight.w700))),
                        ],
                      ),
                      if (_technicalError != null) ...[
                        const SizedBox(height: 8),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Chi tiết kỹ thuật'),
                          children: [
                            SelectableText(_technicalError!),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _copyTechnical,
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Sao chép lỗi'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _ResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiagnosticCard extends StatelessWidget {
  final AiDiagnostic diagnostic;
  const _DiagnosticCard({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final color = diagnostic.ok ? Colors.green : Theme.of(context).colorScheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(diagnostic.ok ? Icons.check_circle : Icons.cancel, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(diagnostic.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(diagnostic.detail),
                  if (diagnostic.model != null) ...[
                    const SizedBox(height: 4),
                    Text('Model: ${diagnostic.model}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                  if (diagnostic.statusCode != null && !diagnostic.ok) ...[
                    const SizedBox(height: 4),
                    Text('HTTP: ${diagnostic.statusCode}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final FoodAnalysis result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.dishName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
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
              const SizedBox(height: 14),
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
        const SizedBox(height: 12),
        ...result.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${item.portion} • P ${item.protein.toStringAsFixed(0)}g • C ${item.carbs.toStringAsFixed(0)}g • F ${item.fat.toStringAsFixed(0)}g'),
                trailing: Text('${item.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
        if (result.note.isNotEmpty)
          Text('Lưu ý: ${result.note}\nĐộ tin cậy: ${result.confidence}', style: Theme.of(context).textTheme.bodySmall),
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
        Text('${value.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label),
      ],
    );
  }
}
