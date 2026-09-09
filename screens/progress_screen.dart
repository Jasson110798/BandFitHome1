import 'package:flutter/material.dart';
import '../services/progress_store.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _currentController = TextEditingController();
  final _targetController = TextEditingController();
  int _completed = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await ProgressStore.getCurrentWeight();
    final target = await ProgressStore.getTargetWeight();
    final completed = await ProgressStore.getCompletedWorkouts();
    if (!mounted) return;
    setState(() {
      if (current != null) _currentController.text = current.toStringAsFixed(1);
      if (target != null) _targetController.text = target.toStringAsFixed(1);
      _completed = completed;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final current = double.tryParse(_currentController.text.replaceAll(',', '.'));
    final target = double.tryParse(_targetController.text.replaceAll(',', '.'));
    if (current == null || target == null || current <= 0 || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hãy nhập cân nặng hợp lệ.')));
      return;
    }
    await ProgressStore.saveWeights(current: current, target: target);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu mục tiêu cân nặng.')));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
              children: [
                Text('Tiến độ', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Theo dõi thói quen tập luyện và mục tiêu của bạn.'),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(28)),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 42),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('$_completed', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                        const Text('buổi tập đã hoàn thành'),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Mục tiêu cân nặng', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        TextField(
                          controller: _currentController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Cân nặng hiện tại', suffixText: 'kg', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _targetController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Mục tiêu', suffixText: 'kg', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(onPressed: _save, child: const Text('Lưu mục tiêu')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Mẹo: cân vào cùng một thời điểm trong ngày và nhìn xu hướng theo nhiều tuần thay vì dao động từng ngày.'),
              ],
            ),
    );
  }
}
