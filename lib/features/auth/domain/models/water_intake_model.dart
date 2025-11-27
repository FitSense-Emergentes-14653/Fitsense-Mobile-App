class WaterIntakeModel {
  final int id;
  final int athleteId;
  final int glasses;
  final DateTime date;
  final int goalGlasses;

  WaterIntakeModel({
    required this.id,
    required this.athleteId,
    required this.glasses,
    required this.date,
    this.goalGlasses = 8,
  });

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'] ?? 0,
      athleteId: json['athlete_id'] ?? 0,
      glasses: json['glasses'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      goalGlasses: json['goal_glasses'] ?? 8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'athlete_id': athleteId,
      'glasses': glasses,
      'date': date.toIso8601String(),
      'goal_glasses': goalGlasses,
    };
  }

  WaterIntakeModel copyWith({
    int? id,
    int? athleteId,
    int? glasses,
    DateTime? date,
    int? goalGlasses,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      glasses: glasses ?? this.glasses,
      date: date ?? this.date,
      goalGlasses: goalGlasses ?? this.goalGlasses,
    );
  }
}

