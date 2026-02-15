import '../models/behavior_profile.dart';
import '../models/activity_log.dart';
import '../models/behavior_profile.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class AdaptiveLearningEngine {
  static final AdaptiveLearningEngine _instance = AdaptiveLearningEngine._internal();
  factory AdaptiveLearningEngine() => _instance;
  AdaptiveLearningEngine._internal();

  final DatabaseService _db = DatabaseService();
  final Uuid _uuid = const Uuid();

  Future<BehaviorProfile> updateBehaviorProfile() async {
    // Get last 7 days of activity
    final activities = await _db.getActivityLogs(7);
    final nudges = await _db.getNudgeLogs(7);

    // Calculate metrics
    double avgSteps = 0;
    if (activities.isNotEmpty) {
      int totalSteps = activities.fold(0, (sum, activity) => sum + activity.steps);
      avgSteps = totalSteps / activities.length;
    }

    // Calculate compliance rate
    double complianceRate = 0;
    if (nudges.isNotEmpty) {
      int compliantActions = nudges.where(
        (n) => n.userAction == 'completed'
      ).length;
      complianceRate = compliantActions / nudges.length;
    } else {
      complianceRate = 0.5; // Default neutral
    }

    // Calculate ignore rate
    double ignoreRate = 0;
    if (nudges.isNotEmpty) {
      int ignoredActions = nudges.where(
        (n) => n.userAction == 'ignored'
      ).length;
      ignoreRate = ignoredActions / nudges.length;
    }

    // Get current profile or create new
    BehaviorProfile? currentProfile = await _db.getBehaviorProfile();
    
    // Calculate dynamic step target
    int dynamicStepTarget = _calculateDynamicTarget(
      avgSteps: avgSteps,
      complianceRate: complianceRate,
      currentTarget: currentProfile?.dynamicStepTarget ?? 10000,
    );

    // Calculate preferred active hour
    int? preferredActiveHour = _calculatePreferredHour(activities);

    final newProfile = BehaviorProfile(
      id: currentProfile?.id ?? _uuid.v4(),
      avgSteps7d: avgSteps,
      complianceRate: complianceRate,
      ignoreRate: ignoreRate,
      dynamicStepTarget: dynamicStepTarget,
      preferredActiveHour: preferredActiveHour,
      updatedAt: DateTime.now(),
    );

    await _db.saveBehaviorProfile(newProfile);
    return newProfile;
  }

  int _calculateDynamicTarget({
    required double avgSteps,
    required double complianceRate,
    required int currentTarget,
  }) {
    int newTarget = currentTarget;

    // Adaptation rules from PRD
    if (complianceRate >= 0.7) {
      // High compliance: increase challenge (max 12k)
      newTarget = (currentTarget + 500).clamp(8000, 12000);
    } else if (complianceRate <= 0.3) {
      // Low compliance: reduce intensity (min 8k)
      newTarget = (currentTarget - 500).clamp(8000, 12000);
    }

    // Also consider average steps
    if (avgSteps > currentTarget * 1.2) {
      // Consistently exceeding target
      newTarget = (avgSteps * 1.1).round().clamp(8000, 12000);
    } else if (avgSteps < currentTarget * 0.6) {
      // Consistently falling short
      newTarget = (avgSteps * 1.3).round().clamp(8000, 12000);
    }

    return newTarget;
  }

  int? _calculatePreferredHour(List<ActivityLog> activities) {
    if (activities.isEmpty) return null;

    // This is a simplified version
    // In a real implementation, would track hourly step data
    // For now, return null (not implemented in basic version)
    return null;
  }

  Future<BehaviorProfile?> getCurrentProfile() async {
    return await _db.getBehaviorProfile();
  }

  Future<void> resetLearning() async {
    final profile = await _db.getBehaviorProfile();
    if (profile != null) {
      final resetProfile = BehaviorProfile(
        id: profile.id,
        avgSteps7d: 0,
        complianceRate: 0.5,
        ignoreRate: 0,
        dynamicStepTarget: 10000,
        preferredActiveHour: null,
        updatedAt: DateTime.now(),
      );
      await _db.saveBehaviorProfile(resetProfile);
    }
  }

  // Predict optimal nudge time based on learning
  int getOptimalNudgeHour(BehaviorProfile? profile) {
    if (profile?.preferredActiveHour != null) {
      // Send nudge 1 hour before preferred active time
      return (profile!.preferredActiveHour! - 1).clamp(0, 23);
    }
    // Default to 8 PM
    return 20;
  }

  // Determine if user is likely to respond to nudge
  bool shouldNudgeUser(BehaviorProfile? profile) {
    if (profile == null) return true;
    
    // Don't nudge if ignore rate is very high
    if (profile.ignoreRate > 0.7) return false;
    
    return true;
  }

  // Get personalized message tone based on compliance
  String getMessageTone(BehaviorProfile? profile) {
    if (profile == null) return 'neutral';
    
    if (profile.complianceRate >= 0.7) {
      return 'encouraging'; // "Keep it up!"
    } else if (profile.complianceRate >= 0.4) {
      return 'neutral'; // "Consider a walk"
    } else {
      return 'gentle'; // "Just a small walk helps"
    }
  }
}
