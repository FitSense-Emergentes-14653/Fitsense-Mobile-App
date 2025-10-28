class AthleteModel {
  final int id;
  final int userId;
  final String fullname;
  final String phone;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String goal;
  final String activityLevel;
  final List<String> equipment;

  AthleteModel({
    required this.id,
    required this.userId,
    required this.fullname,
    required this.phone,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
    required this.activityLevel,
    required this.equipment,
  });

  // ---- fromJson ----
  factory AthleteModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['athleteId'] ?? 0) as num;
    final userId = (json['userId'] ?? 0) as num;
    return AthleteModel(
      id: id.toInt(),
      userId: userId.toInt(),
      fullname: (json['fullname'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      age: (json['age'] ?? 0) is num ? (json['age'] as num).toInt() : 0,
      weight: (json['weight'] ?? 0) is num
          ? (json['weight'] as num).toDouble()
          : double.tryParse(json['weight'].toString()) ?? 0,
      height: (json['height'] ?? 0) is num
          ? (json['height'] as num).toDouble()
          : double.tryParse(json['height'].toString()) ?? 0,
      goal: (json['goal'] ?? '').toString(),
      activityLevel: (json['activityLevel'] ?? '').toString(),
      equipment: (json['equipment'] is List)
          ? List<String>.from(json['equipment'])
          : [],
    );
  }

  // ---- toJson ----
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullname': fullname,
      'phone': phone,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
      'activityLevel': activityLevel,
      'equipment': equipment,
    };
  }

  AthleteModel copyWith({
    int? id,
    int? userId,
    String? fullname,
    String? phone,
    String? gender,
    int? age,
    double? weight,
    double? height,
    String? goal,
    String? activityLevel,
    List<String>? equipment,
  }) {
    return AthleteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      equipment: equipment ?? this.equipment,
    );
  }
}
