class BehaviorProfile {
  final String id;
  final double avgSteps7d;
  final double complianceRate; // 0.0 - 1.0
  final double ignoreRate; // 0.0 - 1.0
  final int dynamicStepTarget;
  final int? preferredActiveHour; // 0-23
  final DateTime updatedAt;

  BehaviorProfile({
    required this.id,
    required this.avgSteps7d,
    required this.complianceRate,
    required this.ignoreRate,
    required this.dynamicStepTarget,
    this.preferredActiveHour,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avg_steps_7d': avgSteps7d,
      'compliance_rate': complianceRate,
      'ignore_rate': ignoreRate,
      'dynamic_step_target': dynamicStepTarget,
      'preferred_active_hour': preferredActiveHour,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BehaviorProfile.fromMap(Map<String, dynamic> map) {
    return BehaviorProfile(
      id: map['id'],
      avgSteps7d: map['avg_steps_7d'].toDouble(),
      complianceRate: map['compliance_rate'].toDouble(),
      ignoreRate: map['ignore_rate'].toDouble(),
      dynamicStepTarget: map['dynamic_step_target'],
      preferredActiveHour: map['preferred_active_hour'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BehaviorProfile copyWith({
    String? id,
    double? avgSteps7d,
    double? complianceRate,
    double? ignoreRate,
    int? dynamicStepTarget,
    int? preferredActiveHour,
    DateTime? updatedAt,
  }) {
    return BehaviorProfile(
      id: id ?? this.id,
      avgSteps7d: avgSteps7d ?? this.avgSteps7d,
      complianceRate: complianceRate ?? this.complianceRate,
      ignoreRate: ignoreRate ?? this.ignoreRate,
      dynamicStepTarget: dynamicStepTarget ?? this.dynamicStepTarget,
      preferredActiveHour: preferredActiveHour ?? this.preferredActiveHour,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NudgeLog {
  final String id;
  final DateTime date;
  final String decision; // sent, suppressed, ignored
  final String userAction; // completed, ignored, dismissed
  final int calorieOverage;
  final int stepDeficit;
  final DateTime createdAt;

  NudgeLog({
    required this.id,
    required this.date,
    required this.decision,
    required this.userAction,
    required this.calorieOverage,
    required this.stepDeficit,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'decision': decision,
      'user_action': userAction,
      'calorie_overage': calorieOverage,
      'step_deficit': stepDeficit,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NudgeLog.fromMap(Map<String, dynamic> map) {
    return NudgeLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      decision: map['decision'],
      userAction: map['user_action'],
      calorieOverage: map['calorie_overage'],
      stepDeficit: map['step_deficit'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class WeeklyIntelligence {
  final double weeklyDeficit;
  final double avgSteps;
  final double avgCalories;
  final int daysCompliant;
  final String advisory;
  final DateTime weekStart;
  final DateTime weekEnd;

  WeeklyIntelligence({
    required this.weeklyDeficit,
    required this.avgSteps,
    required this.avgCalories,
    required this.daysCompliant,
    required this.advisory,
    required this.weekStart,
    required this.weekEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekly_deficit': weeklyDeficit,
      'avg_steps': avgSteps,
      'avg_calories': avgCalories,
      'days_compliant': daysCompliant,
      'advisory': advisory,
      'week_start': weekStart.toIso8601String(),
      'week_end': weekEnd.toIso8601String(),
    };
  }

  factory WeeklyIntelligence.fromMap(Map<String, dynamic> map) {
    return WeeklyIntelligence(
      weeklyDeficit: map['weekly_deficit'].toDouble(),
      avgSteps: map['avg_steps'].toDouble(),
      avgCalories: map['avg_calories'].toDouble(),
      daysCompliant: map['days_compliant'],
      advisory: map['advisory'],
      weekStart: DateTime.parse(map['week_start']),
      weekEnd: DateTime.parse(map['week_end']),
    );
  }
}
