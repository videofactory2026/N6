import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/activity_log.dart';
import 'dart:async';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();
  StreamSubscription<StepCount>? _pedometerSubscription;
  int _fallbackSteps = 0;

  // Health Connect data types
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<bool> requestPermissions() async {
    // Request activity recognition permission
    final activityPermission = await Permission.activityRecognition.request();
    
    if (activityPermission.isGranted) {
      // Request Health Connect permissions
      bool? hasPermissions = await _health.hasPermissions(_types);
      
      if (hasPermissions == false) {
        hasPermissions = await _health.requestAuthorization(_types);
      }
      
      return hasPermissions ?? false;
    }
    
    return false;
  }

  Future<ActivityLog?> getTodayActivity() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    try {
      // Try Health Connect first
      final healthData = await _health.getHealthDataFromTypes(
        startOfDay,
        now,
        _types,
      );

      if (healthData.isNotEmpty) {
        return _parseHealthData(healthData, startOfDay);
      }
    } catch (e) {
      print('Health Connect error: $e');
    }

    // Fallback to pedometer
    return _getFallbackActivity(startOfDay);
  }

  ActivityLog _parseHealthData(List<HealthDataPoint> data, DateTime date) {
    int totalSteps = 0;
    double totalDistance = 0;
    int activeMinutes = 0;

    // Aggregate data to avoid double counting
    Map<String, HealthDataPoint> latestDataPoints = {};

    for (var point in data) {
      String key = '${point.type}_${point.dateFrom}';
      
      // Keep only the latest data point for each timestamp
      if (!latestDataPoints.containsKey(key) || 
          point.dateTo.isAfter(latestDataPoints[key]!.dateTo)) {
        latestDataPoints[key] = point;
      }
    }

    for (var point in latestDataPoints.values) {
      if (point.type == HealthDataType.STEPS) {
        totalSteps += (point.value as num).toInt();
      } else if (point.type == HealthDataType.DISTANCE_DELTA) {
        totalDistance += (point.value as num).toDouble() / 1000; // Convert to km
      }
    }

    // Estimate active minutes (rough calculation)
    activeMinutes = (totalSteps / 100).round(); // ~100 steps per minute

    return ActivityLog(
      id: 'activity_${date.toIso8601String()}',
      date: date,
      steps: totalSteps,
      distance: totalDistance,
      activeMinutes: activeMinutes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<ActivityLog> _getFallbackActivity(DateTime date) async {
    // Initialize pedometer if not already
    if (_pedometerSubscription == null) {
      _initPedometer();
    }

    return ActivityLog(
      id: 'activity_${date.toIso8601String()}',
      date: date,
      steps: _fallbackSteps,
      distance: _fallbackSteps / 1300, // Rough estimate: ~1300 steps per km
      activeMinutes: (_fallbackSteps / 100).round(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _initPedometer() {
    try {
      _pedometerSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          _fallbackSteps = event.steps;
        },
        onError: (error) {
          print('Pedometer error: $error');
        },
      );
    } catch (e) {
      print('Failed to init pedometer: $e');
    }
  }

  Future<void> startBackgroundSync() async {
    // Background sync every 30 minutes
    Timer.periodic(const Duration(minutes: 30), (timer) async {
      await getTodayActivity();
    });
  }

  void dispose() {
    _pedometerSubscription?.cancel();
  }

  // Manual override
  Future<ActivityLog> createManualActivity(int steps, DateTime date) async {
    return ActivityLog(
      id: 'activity_${date.toIso8601String()}',
      date: date,
      steps: steps,
      distance: steps / 1300,
      activeMinutes: (steps / 100).round(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
