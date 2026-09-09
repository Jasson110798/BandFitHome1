import 'package:flutter/material.dart';
import '../data/workouts.dart';
import '../models/workout_plan.dart';
import 'plan_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
        children: [
          Text('BandFit Home', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Tập với dây kháng lực • Không cần phòng gym', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mục tiêu hôm nay', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(.8))),
                const SizedBox(height: 8),
                Text('20 phút vận động là một khởi đầu rất tốt.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text('Chọn mức dây vừa sức. Khi kỹ thuật bắt đầu xấu đi, hãy giảm lực cản hoặc nghỉ.', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(.85))),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: Text('Chương trình tập', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              Text('${workouts.length} chương trình', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(workouts.length, (index) => _PlanCard(plan: workouts[index], index: index)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Giảm cân phụ thuộc cả vận động, dinh dưỡng, giấc ngủ và tổng năng lượng nạp vào. App hỗ trợ luyện tập, không thay thế tư vấn y tế.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final int index;
  const _PlanCard({required this.plan, required this.index});

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.spa_outlined, Icons.local_fire_department_outlined, Icons.directions_walk, Icons.fitness_center];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlanDetailScreen(plan: plan))),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(18)),
                  child: Icon(icons[index % icons.length]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('${plan.level} • ${plan.durationLabel}'),
                      const SizedBox(height: 3),
                      Text(plan.focus, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
