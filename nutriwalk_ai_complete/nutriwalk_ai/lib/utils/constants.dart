class AppConstants {
  // App Info
  static const String appName = 'NutriWalk AI';
  static const String appVersion = '1.0.0';
  
  // Calorie & Movement Constants
  static const int defaultStepTarget = 10000;
  static const int minStepTarget = 8000;
  static const int maxStepTarget = 12000;
  static const double defaultCalorieDeficit = 500;
  
  // Time Windows
  static const int eveningNudgeStartHour = 20; // 8 PM
  static const int eveningNudgeEndHour = 21;   // 9 PM
  
  // Suppression Rules
  static const int maxNudgesPerDay = 1;
  static const int maxIgnoredNudgesBeforeSuppression = 3;
  static const int suppressionLookbackDays = 7;
  
  // Learning Thresholds
  static const double highComplianceThreshold = 0.7;
  static const double lowComplianceThreshold = 0.3;
  
  // Plateau Detection
  static const int plateauDetectionDays = 14;
  static const double plateauWeightThreshold = 0.5; // kg
  
  // AI Recognition
  static const double aiConfidenceThreshold = 0.5;
  static const int aiTimeoutSeconds = 5;
  static const int maxImageDimension = 1024;
  static const int imageQuality = 85;
  
  // Portion Multipliers
  static const double minPortionMultiplier = 0.5;
  static const double maxPortionMultiplier = 2.0;
  static const double defaultPortionMultiplier = 1.0;
  
  // Background Sync
  static const int backgroundSyncIntervalMinutes = 30;
  
  // Weekly Intelligence
  static const int weeklyDeficitGoodThreshold = 3500; // calories
  static const int weeklyDeficitOkThreshold = 1500;
  static const int weeklyDeficitSuppressThreshold = 500;
  
  // Activity Multipliers
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };
  
  // Database
  static const String databaseName = 'nutriwalk_ai.db';
  static const int databaseVersion = 1;
}

class UiConstants {
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
}
