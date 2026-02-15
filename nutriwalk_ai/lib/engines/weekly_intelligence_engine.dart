import '../models/user_profile.dart';
import '../models/meal_log.dart';
import '../models/activity_log.dart';
import '../models/behavior_profile.dart';
import '../services/database_service.dart';

class WeeklyIntelligenceEngine {
  static final WeeklyIntelligenceEngine _instance = WeeklyIntelligenceEngine._internal();
  factory WeeklyIntelligenceEngine() => _instance;
  WeeklyIntelligenceEngine._internal();

  final DatabaseService _db = DatabaseService();

  Future<WeeklyIntelligence> calculateWeeklyIntelligence(UserProfile profile) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    // Get last 7 days of data
    final meals = await _db.getMealLogs(weekStartMidnight, now);
    final activities = await _db.getActivityLogs(7);

    // Calculate weekly totals
    double totalCaloriesIn = 0;
    double totalCaloriesBurned = 0;
    int totalSteps = 0;
    int daysCompliant = 0;

    // Group meals by day
    Map<String, double> dailyCalories = {};
    for (var meal in meals) {
      String dateKey = _getDateKey(meal.date);
      dailyCalories[dateKey] = (dailyCalories[dateKey] ?? 0) + meal.totalCalories;
      totalCaloriesIn += meal.totalCalories;
    }

    // Process activities
    for (var activity in activities) {
      totalSteps += activity.steps;
      double caloriesBurned = activity.distance * profile.caloriesPerKm;
      totalCaloriesBurned += caloriesBurned;

      // Check if day was compliant
      String dateKey = _getDateKey(activity.date);
      double dayCalories = dailyCalories[dateKey] ?? 0;
      double dayNet = dayCalories - caloriesBurned;
      
      if (dayNet <= profile.dailyCalorieTarget + 200) {
        daysCompliant++;
      }
    }

    // Calculate weekly deficit
    final weeklyCalorieTarget = profile.dailyCalorieTarget * 7;
    final weeklyNet = totalCaloriesIn - totalCaloriesBurned;
    final weeklyDeficit = weeklyCalorieTarget - weeklyNet;

    // Calculate averages
    final avgSteps = activities.isNotEmpty ? totalSteps / activities.length : 0;
    final avgCalories = dailyCalories.isNotEmpty 
        ? totalCaloriesIn / dailyCalories.length 
        : 0;

    // Generate advisory
    final advisory = _generateAdvisory(
      weeklyDeficit: weeklyDeficit,
      daysCompliant: daysCompliant,
      avgSteps: avgSteps,
    );

    return WeeklyIntelligence(
      weeklyDeficit: weeklyDeficit,
      avgSteps: avgSteps,
      avgCalories: avgCalories,
      daysCompliant: daysCompliant,
      advisory: advisory,
      weekStart: weekStartMidnight,
      weekEnd: now,
    );
  }

  String _generateAdvisory({
    required double weeklyDeficit,
    required int daysCompliant,
    required double avgSteps,
  }) {
    if (weeklyDeficit >= 3500) {
      return '🎉 Excellent week! You\'re on track for 0.5kg loss. Keep it up!';
    } else if (weeklyDeficit >= 1500) {
      return '✅ Good progress! You\'re creating a healthy deficit.';
    } else if (weeklyDeficit >= 0) {
      return '📊 Maintaining balance. Consider increasing activity for faster results.';
    } else if (weeklyDeficit >= -1500) {
      return '⚠️ Slight surplus this week. Focus on portion control and movement.';
    } else {
      return '🔄 Significant surplus. Let\'s refocus on your goals next week.';
    }
  }

  bool shouldSuppressDailyNudge(WeeklyIntelligence intelligence) {
    // If weekly deficit is good (>= 500 cal), don't aggressively nudge daily
    return intelligence.weeklyDeficit >= 500;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
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
