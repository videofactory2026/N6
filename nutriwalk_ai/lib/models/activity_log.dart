class WeightLog {
  final String id;
  final DateTime date;
  final double weight; // in kg
  final DateTime createdAt;

  WeightLog({
    required this.id,
    required this.date,
    required this.weight,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WeightLog.fromMap(Map<String, dynamic> map) {
    return WeightLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      weight: map['weight'].toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class ActivityLog {
  final String id;
  final DateTime date;
  final int steps;
  final double distance; // in km
  final int activeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityLog({
    required this.id,
    required this.date,
    required this.steps,
    required this.distance,
    required this.activeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'active_minutes': activeMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      distance: map['distance'].toDouble(),
      activeMinutes: map['active_minutes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  ActivityLog copyWith({
    String? id,
    DateTime? date,
    int? steps,
    double? distance,
    int? activeMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
