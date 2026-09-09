import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import 'workout_screen.dart';

class PlanDetailScreen extends StatelessWidget {
  final WorkoutPlan plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.focus, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(plan.subtitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(text: plan.level, icon: Icons.signal_cellular_alt),
                      _Chip(text: plan.durationLabel, icon: Icons.timer_outlined),
                      _Chip(text: '${plan.exercises.length} động tác', icon: Icons.fitness_center),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Danh sách bài tập', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...List.generate(plan.exercises.length, (index) {
              final ex = plan.exercises[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(child: Text(ex.emoji)),
                    title: Text('${index + 1}. ${ex.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${ex.muscle} • ${ex.band}\n${ex.durationSec}s tập • ${ex.restSec}s nghỉ'),
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: FilledButton.icon(
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Bắt đầu buổi tập', style: TextStyle(fontWeight: FontWeight.w800)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkoutScreen(plan: plan)),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Chip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.65),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(text)],
      ),
    );
  }
}
