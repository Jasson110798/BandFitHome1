import 'exercise.dart';

class WorkoutPlan {
  final String name;
  final String subtitle;
  final String level;
  final String durationLabel;
  final String focus;
  final List<Exercise> exercises;

  const WorkoutPlan({
    required this.name,
    required this.subtitle,
    required this.level,
    required this.durationLabel,
    required this.focus,
    required this.exercises,
  });
}
