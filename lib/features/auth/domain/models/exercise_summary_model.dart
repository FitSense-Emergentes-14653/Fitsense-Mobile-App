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

    return ExerciseSummaryModel(
      userId: data['userId']?.toString() ?? '0',
      routineId: data['routineId'] ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.parse(data['lastUpdated'])
          : DateTime.now(),
      totalCaloriesBurned: data['totalCaloriesBurned'] ?? 0,
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

