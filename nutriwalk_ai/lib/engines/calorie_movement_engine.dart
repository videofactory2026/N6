import '../models/user_profile.dart';
import '../models/meal_log.dart';
import '../models/activity_log.dart';

class CalorieMovementEngine {
  static final CalorieMovementEngine _instance = CalorieMovementEngine._internal();
  factory CalorieMovementEngine() => _instance;
  CalorieMovementEngine._internal();

  MovementRecommendation calculateMovement({
    required UserProfile profile,
    required double caloriesConsumed,
    required int currentSteps,
  }) {
    final calorieTarget = profile.dailyCalorieTarget;
    final calorieDeficit = calorieTarget - caloriesConsumed;

    // If already in deficit, minimal movement needed
    if (calorieDeficit >= 0) {
      return MovementRecommendation(
        stepsRequired: 8000, // Baseline recommendation
        distanceKm: 8000 / profile.stepsPerKm,
        minutesRequired: 80,
        caloriesBurned: 8000 / profile.stepsPerKm * profile.caloriesPerKm,
        message: 'You\'re on target! Keep up the good work with baseline activity.',
        urgency: 'low',
      );
    }

    // Calculate steps needed to burn excess calories
    final caloriesPerKm = profile.caloriesPerKm;
    final kmNeeded = calorieDeficit.abs() / caloriesPerKm;
    final stepsNeeded = (kmNeeded * profile.stepsPerKm).round();
    
    // Calculate total steps target (current + needed)
    final totalStepsTarget = currentSteps + stepsNeeded;
    
    // Cap at reasonable maximum (15000 steps)
    final cappedStepsTarget = totalStepsTarget > 15000 ? 15000 : totalStepsTarget;
    final actualStepsNeeded = cappedStepsTarget - currentSteps;
    
    // Calculate time estimate (assumes ~100 steps per minute)
    final minutesRequired = (actualStepsNeeded / 100).round();
    
    // Calculate actual distance and calories for the capped value
    final actualDistanceKm = actualStepsNeeded / profile.stepsPerKm;
    final actualCaloriesBurned = actualDistanceKm * caloriesPerKm;

    // Determine urgency and message
    String urgency;
    String message;

    if (actualStepsNeeded < 2000) {
      urgency = 'low';
      message = 'A short walk will balance things out!';
    } else if (actualStepsNeeded < 5000) {
      urgency = 'medium';
      message = 'Take a good walk to balance today\'s intake.';
    } else {
      urgency = 'high';
      message = 'Consider an evening walk or light jog to stay on track.';
    }

    return MovementRecommendation(
      stepsRequired: actualStepsNeeded,
      distanceKm: actualDistanceKm,
      minutesRequired: minutesRequired,
      caloriesBurned: actualCaloriesBurned,
      message: message,
      urgency: urgency,
    );
  }

  String getBeforeSleepSuggestion(MovementRecommendation recommendation) {
    if (recommendation.urgency == 'low') {
      return '🌙 Light evening stretch or short walk (${recommendation.minutesRequired} min)';
    } else if (recommendation.urgency == 'medium') {
      return '🚶 Evening walk recommended: ${recommendation.distanceKm.toStringAsFixed(1)}km (${recommendation.minutesRequired} min)';
    } else {
      return '⚡ Active evening needed: ${recommendation.distanceKm.toStringAsFixed(1)}km walk/jog (${recommendation.minutesRequired} min)';
    }
  }

  DailyBalance calculateDailyBalance({
    required UserProfile profile,
    required List<MealLog> meals,
    required ActivityLog? activity,
  }) {
    final totalCaloriesIn = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );

    final calorieTarget = profile.dailyCalorieTarget;
    final steps = activity?.steps ?? 0;
    final distanceKm = activity?.distance ?? 0;
    final caloriesBurned = distanceKm * profile.caloriesPerKm;

    final netCalories = totalCaloriesIn - caloriesBurned;
    final deficit = calorieTarget - netCalories;
    
    final isOnTrack = deficit >= -200; // Allow 200 calorie buffer

    return DailyBalance(
      caloriesIn: totalCaloriesIn,
      caloriesBurned: caloriesBurned,
      netCalories: netCalories,
      deficit: deficit,
      steps: steps,
      isOnTrack: isOnTrack,
      targetCalories: calorieTarget,
    );
  }
}

class MovementRecommendation {
  final int stepsRequired;
  final double distanceKm;
  final int minutesRequired;
  final double caloriesBurned;
  final String message;
  final String urgency; // low, medium, high

  MovementRecommendation({
    required this.stepsRequired,
    required this.distanceKm,
    required this.minutesRequired,
    required this.caloriesBurned,
    required this.message,
    required this.urgency,
  });
}

class DailyBalance {
  final double caloriesIn;
  final double caloriesBurned;
  final double netCalories;
  final double deficit;
  final int steps;
  final bool isOnTrack;
  final double targetCalories;

  DailyBalance({
    required this.caloriesIn,
    required this.caloriesBurned,
    required this.netCalories,
    required this.deficit,
    required this.steps,
    required this.isOnTrack,
    required this.targetCalories,
  });

  double get deficitPercentage => (deficit / targetCalories) * 100;
}
