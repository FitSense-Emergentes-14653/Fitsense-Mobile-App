class MealModel {
  final int id;
  final int athleteId;
  final String name;
  final String mealType; // breakfast, lunch, dinner, snack
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime date;

  MealModel({
    required this.id,
    required this.athleteId,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] ?? 0,
      athleteId: json['athlete_id'] ?? 0,
      name: json['name'] ?? '',
      mealType: json['meal_type'] ?? 'snack',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'athlete_id': athleteId,
      'name': name,
      'meal_type': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'date': date.toIso8601String(),
    };
  }
}

class DailyCaloriesSummary {
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final int goalCalories;
  final List<MealModel> meals;

  DailyCaloriesSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.goalCalories,
    required this.meals,
  });

  double get progress => goalCalories > 0 ? (totalCalories / goalCalories) : 0.0;
  int get remainingCalories => goalCalories - totalCalories;
}

