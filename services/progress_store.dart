import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  static const _currentWeightKey = 'current_weight';
  static const _targetWeightKey = 'target_weight';
  static const _completedKey = 'completed_workouts';

  static Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_currentWeightKey);
  }

  static Future<double?> getTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetWeightKey);
  }

  static Future<int> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedKey) ?? 0;
  }

  static Future<void> saveWeights({required double current, required double target}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_currentWeightKey, current);
    await prefs.setDouble(_targetWeightKey, target);
  }

  static Future<void> addCompletedWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_completedKey) ?? 0;
    await prefs.setInt(_completedKey, count + 1);
  }
}
