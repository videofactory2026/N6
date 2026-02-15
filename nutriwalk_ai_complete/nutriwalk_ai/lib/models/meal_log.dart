class MealLog {
  final String id;
  final DateTime date;
  final List<FoodItem> items;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final String? imagePath;
  final DateTime createdAt;

  MealLog({
    required this.id,
    required this.date,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((item) => FoodItem.fromMap(item))
          .toList(),
      totalCalories: map['total_calories'].toDouble(),
      totalProtein: map['total_protein'].toDouble(),
      totalCarbs: map['total_carbs'].toDouble(),
      totalFat: map['total_fat'].toDouble(),
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double portionMultiplier; // 0.5x - 2x
  final double confidence; // AI confidence score

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.portionMultiplier = 1.0,
    this.confidence = 0.0,
  });

  double get adjustedCalories => calories * portionMultiplier;
  double get adjustedProtein => protein * portionMultiplier;
  double get adjustedCarbs => carbs * portionMultiplier;
  double get adjustedFat => fat * portionMultiplier;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'portion_multiplier': portionMultiplier,
      'confidence': confidence,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'],
      calories: map['calories'].toDouble(),
      protein: map['protein'].toDouble(),
      carbs: map['carbs'].toDouble(),
      fat: map['fat'].toDouble(),
      portionMultiplier: map['portion_multiplier']?.toDouble() ?? 1.0,
      confidence: map['confidence']?.toDouble() ?? 0.0,
    );
  }

  FoodItem copyWith({
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? portionMultiplier,
    double? confidence,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      portionMultiplier: portionMultiplier ?? this.portionMultiplier,
      confidence: confidence ?? this.confidence,
    );
  }
}
