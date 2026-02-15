class UserProfile {
  final String id;
  final int age;
  final double height; // in cm
  final double currentWeight; // in kg
  final double goalWeight; // in kg
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final String gender; // male, female
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.age,
    required this.height,
    required this.currentWeight,
    required this.goalWeight,
    required this.activityLevel,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate BMR using Mifflin-St Jeor equation
  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE
  double get tdee {
    Map<String, double> activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (activityMultipliers[activityLevel] ?? 1.2);
  }

  // Calculate daily calorie target (deficit of 500 for fat loss)
  double get dailyCalorieTarget => tdee - 500;

  // Calculate calories burned per km based on weight
  double get caloriesPerKm => 0.7 * currentWeight;

  // Calculate steps per km based on height
  int get stepsPerKm {
    double strideLength = height * 0.43; // in cm
    return (100000 / strideLength).round(); // 1km = 100,000cm
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'height': height,
      'current_weight': currentWeight,
      'goal_weight': goalWeight,
      'activity_level': activityLevel,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      age: map['age'],
      height: map['height'].toDouble(),
      currentWeight: map['current_weight'].toDouble(),
      goalWeight: map['goal_weight'].toDouble(),
      activityLevel: map['activity_level'],
      gender: map['gender'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  UserProfile copyWith({
    String? id,
    int? age,
    double? height,
    double? currentWeight,
    double? goalWeight,
    String? activityLevel,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
