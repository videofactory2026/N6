import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/meal_log.dart';
import '../models/activity_log.dart';
import '../models/behavior_profile.dart';
import '../services/database_service.dart';
import '../services/health_service.dart';
import '../engines/calorie_movement_engine.dart';
import '../engines/weekly_intelligence_engine.dart';
import '../engines/adaptive_learning_engine.dart';

class AppStateProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final HealthService _health = HealthService();
  final CalorieMovementEngine _movementEngine = CalorieMovementEngine();
  final WeeklyIntelligenceEngine _weeklyEngine = WeeklyIntelligenceEngine();
  final AdaptiveLearningEngine _learningEngine = AdaptiveLearningEngine();

  UserProfile? _userProfile;
  List<MealLog> _todayMeals = [];
  ActivityLog? _todayActivity;
  BehaviorProfile? _behaviorProfile;
  WeeklyIntelligence? _weeklyIntelligence;
  MovementRecommendation? _movementRecommendation;
  DailyBalance? _dailyBalance;

  bool _isLoading = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  List<MealLog> get todayMeals => _todayMeals;
  ActivityLog? get todayActivity => _todayActivity;
  BehaviorProfile? get behaviorProfile => _behaviorProfile;
  WeeklyIntelligence? get weeklyIntelligence => _weeklyIntelligence;
  MovementRecommendation? get movementRecommendation => _movementRecommendation;
  DailyBalance? get dailyBalance => _dailyBalance;
  bool get isLoading => _isLoading;

  double get todayCalories {
    return _todayMeals.fold(0, (sum, meal) => sum + meal.totalCalories);
  }

  int get todaySteps => _todayActivity?.steps ?? 0;

  Future<void> loadUserProfile() async {
    _userProfile = await _db.getUserProfile();
    notifyListeners();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _db.saveUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> loadTodayData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayMeals = await _db.getTodayMeals();
      _todayActivity = await _health.getTodayActivity();
      
      if (_todayActivity != null) {
        await _db.saveActivityLog(_todayActivity!);
      }

      await _calculateDailyMetrics();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading today data: $e');
    }
  }

  Future<void> addMeal(MealLog meal) async {
    await _db.saveMealLog(meal);
    _todayMeals.add(meal);
    await _calculateDailyMetrics();
    notifyListeners();
  }

  Future<void> updateMeal(MealLog meal) async {
    await _db.saveMealLog(meal);
    int index = _todayMeals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _todayMeals[index] = meal;
    }
    await _calculateDailyMetrics();
    notifyListeners();
  }

  Future<void> deleteMeal(String mealId) async {
    _todayMeals.removeWhere((m) => m.id == mealId);
    await _calculateDailyMetrics();
    notifyListeners();
  }

  Future<void> _calculateDailyMetrics() async {
    if (_userProfile == null) return;

    // Calculate movement recommendation
    _movementRecommendation = _movementEngine.calculateMovement(
      profile: _userProfile!,
      caloriesConsumed: todayCalories,
      currentSteps: todaySteps,
    );

    // Calculate daily balance
    _dailyBalance = _movementEngine.calculateDailyBalance(
      profile: _userProfile!,
      meals: _todayMeals,
      activity: _todayActivity,
    );
  }

  Future<void> loadWeeklyIntelligence() async {
    if (_userProfile == null) return;
    
    _weeklyIntelligence = await _weeklyEngine.calculateWeeklyIntelligence(_userProfile!);
    notifyListeners();
  }

  Future<void> loadBehaviorProfile() async {
    _behaviorProfile = await _learningEngine.getCurrentProfile();
    notifyListeners();
  }

  Future<void> updateBehaviorProfile() async {
    _behaviorProfile = await _learningEngine.updateBehaviorProfile();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await loadUserProfile();
    await loadTodayData();
    await loadWeeklyIntelligence();
    await loadBehaviorProfile();
  }
}
