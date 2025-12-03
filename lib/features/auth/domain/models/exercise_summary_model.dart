class ExerciseSummaryModel {
  final String userId;
  final int routineId;
  final int exercisesCompleted;
  final DateTime lastUpdated;
  final int totalCaloriesBurned;

  ExerciseSummaryModel({
    required this.userId,
    required this.routineId,
    required this.exercisesCompleted,
    required this.lastUpdated,
    required this.totalCaloriesBurned,
  });

  factory ExerciseSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    // Convertir totalCaloriesBurned de double a int de manera segura
    int calories = 0;
    if (data['totalCaloriesBurned'] != null) {
      if (data['totalCaloriesBurned'] is double) {
        calories = (data['totalCaloriesBurned'] as double).toInt();
      } else if (data['totalCaloriesBurned'] is int) {
        calories = data['totalCaloriesBurned'] as int;
      } else {
        calories = int.tryParse(data['totalCaloriesBurned'].toString()) ?? 0;
      }
    }

    return ExerciseSummaryModel(
      userId: data['userId']?.toString() ?? '0',
      routineId: data['routineId'] ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.parse(data['lastUpdated'])
          : DateTime.now(),
      totalCaloriesBurned: calories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'routineId': routineId,
      'exercisesCompleted': exercisesCompleted,
      'lastUpdated': lastUpdated.toIso8601String(),
      'totalCaloriesBurned': totalCaloriesBurned,
    };
  }
}

