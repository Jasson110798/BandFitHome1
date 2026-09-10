class FoodItemEstimate {
  final String name;
  final String portion;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodItemEstimate({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodItemEstimate.fromJson(Map<String, dynamic> json) => FoodItemEstimate(
        name: json['name']?.toString() ?? 'Món ăn',
        portion: json['portion']?.toString() ?? 'Không rõ',
        calories: (json['calories'] as num?)?.round() ?? 0,
        protein: (json['protein_g'] as num?)?.toDouble() ?? 0,
        carbs: (json['carbs_g'] as num?)?.toDouble() ?? 0,
        fat: (json['fat_g'] as num?)?.toDouble() ?? 0,
      );
}

class FoodAnalysis {
  final String dishName;
  final int totalCalories;
  final double protein;
  final double carbs;
  final double fat;
  final String confidence;
  final String note;
  final List<FoodItemEstimate> items;

  const FoodAnalysis({
    required this.dishName,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.note,
    required this.items,
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return FoodAnalysis(
      dishName: json['dish_name']?.toString() ?? 'Bữa ăn',
      totalCalories: (json['total_calories'] as num?)?.round() ?? 0,
      protein: (json['protein_g'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      fat: (json['fat_g'] as num?)?.toDouble() ?? 0,
      confidence: json['confidence']?.toString() ?? 'medium',
      note: json['note']?.toString() ?? '',
      items: rawItems.whereType<Map>().map((e) => FoodItemEstimate.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
