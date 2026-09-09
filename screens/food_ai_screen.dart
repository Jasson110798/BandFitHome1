import 'dart:io';
import 'package:flutter/material.dart';
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
    final file = await _picker.pickImage(source: source, imageQuality: 82, maxWidth: 1600);
    if (file == null) return;
    setState(() { _image = file; _result = null; _error = null; });
    await _analyze();
  }

  Future<void> _analyze() async {
    final image = _image;
    if (image == null) return;
    if (!_service.isConfigured) {
      setState(() => _error = 'AI chưa được kích hoạt. Hãy thêm GEMINI_API_KEY vào GitHub Secret rồi build lại APK.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final bytes = await image.readAsBytes();
      final ext = image.path.toLowerCase();
      final mime = ext.endsWith('.png') ? 'image/png' : ext.endsWith('.webp') ? 'image/webp' : 'image/jpeg';
      final result = await _service.analyze(bytes, mimeType: mime);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Text('AI Calo', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('Chụp món ăn để AI ước tính calories và macro.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(26)),
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                const Icon(Icons.auto_awesome, size: 30),
                const SizedBox(width: 12),
                Expanded(child: Text('Kết quả từ ảnh chỉ là ước tính. Dầu, sốt và khối lượng thực tế có thể làm calories lệch đáng kể.', style: Theme.of(context).textTheme.bodyMedium)),
              ]),
            ),
            const SizedBox(height: 18),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(aspectRatio: 4 / 3, child: Image.file(File(_image!.path), fit: BoxFit.cover)),
              )
            else
              Container(
                height: 230,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.restaurant_menu, size: 64), SizedBox(height: 12), Text('Chưa có ảnh món ăn', style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
              ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: _loading ? null : () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Chụp ảnh'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Thư viện'))),
            ]),
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              const Center(child: Text('AI đang nhận diện món và ước tính khẩu phần…')),
            ],
            if (_error != null) ...[
              const SizedBox(height: 18),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.error), const SizedBox(width: 10), Expanded(child: Text(_error!)),
              ]))),
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

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(result.dishName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          Text('${result.totalCalories}', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900)),
          const Text('kcal ước tính'), const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Macro('Protein', result.protein), _Macro('Carb', result.carbs), _Macro('Fat', result.fat),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      ...result.items.map((item) => Card(child: ListTile(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${item.portion} • P ${item.protein.toStringAsFixed(0)}g • C ${item.carbs.toStringAsFixed(0)}g • F ${item.fat.toStringAsFixed(0)}g'),
        trailing: Text('${item.calories} kcal', style: const TextStyle(fontWeight: FontWeight.w800)),
      ))),
      if (result.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Lưu ý: ${result.note}\nĐộ tin cậy: ${result.confidence}', style: Theme.of(context).textTheme.bodySmall)),
    ]);
  }
}

class _Macro extends StatelessWidget {
  final String label; final double value;
  const _Macro(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [Text('${value.toStringAsFixed(0)}g', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), Text(label)]);
}
