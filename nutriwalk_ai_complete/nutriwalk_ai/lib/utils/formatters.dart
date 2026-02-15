import 'package:intl/intl.dart';

class AppFormatters {
  // Date formatters
  static final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat timeFormat = DateFormat('h:mm a');
  static final DateFormat dateTimeFormat = DateFormat('MMM dd, yyyy h:mm a');
  
  // Number formatters
  static String formatCalories(double calories) {
    return '${calories.round()} kcal';
  }
  
  static String formatSteps(int steps) {
    if (steps >= 10000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }
  
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
  
  static String formatWeight(double kg) {
    return '${kg.toStringAsFixed(1)} kg';
  }
  
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours hr';
    }
    return '$hours hr $mins min';
  }
  
  static String formatPercentage(double value) {
    return '${(value * 100).round()}%';
  }
  
  static String formatMacro(double grams, String label) {
    return '$label: ${grams.round()}g';
  }
}
