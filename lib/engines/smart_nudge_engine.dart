import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/user_profile.dart';
import '../models/behavior_profile.dart';
import '../models/behavior_profile.dart';
import '../services/database_service.dart';
import '../engines/weekly_intelligence_engine.dart';
import '../engines/adaptive_learning_engine.dart';
import 'package:uuid/uuid.dart';

class SmartNudgeEngine {
  static final SmartNudgeEngine _instance = SmartNudgeEngine._internal();
  factory SmartNudgeEngine() => _instance;
  SmartNudgeEngine._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final DatabaseService _db = DatabaseService();
  final WeeklyIntelligenceEngine _weeklyEngine = WeeklyIntelligenceEngine();
  final AdaptiveLearningEngine _learningEngine = AdaptiveLearningEngine();
  final Uuid _uuid = const Uuid();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> shouldSendNudge({
    required UserProfile profile,
    required double caloriesConsumed,
    required int currentSteps,
  }) async {
    // Check time window (8:00 PM - 9:00 PM)
    final now = DateTime.now();
    if (now.hour < 20 || now.hour >= 21) {
      return false;
    }

    // Check if calories > target
    if (caloriesConsumed <= profile.dailyCalorieTarget) {
      return false;
    }

    // Check if steps < dynamic target
    final behaviorProfile = await _db.getBehaviorProfile();
    final stepTarget = behaviorProfile?.dynamicStepTarget ?? 10000;
    
    if (currentSteps >= stepTarget) {
      return false;
    }

    // Check weekly deficit (no aggressive nudge if weekly deficit sufficient)
    final weeklyIntel = await _weeklyEngine.calculateWeeklyIntelligence(profile);
    if (_weeklyEngine.shouldSuppressDailyNudge(weeklyIntel)) {
      return false;
    }

    // Check suppression rules
    if (await _isSuppressed()) {
      return false;
    }

    return true;
  }

  Future<bool> _isSuppressed() async {
    final nudges = await _db.getNudgeLogs(7);
    
    // Max 1 nudge per day
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayNudges = nudges.where(
      (n) => n.date.isAfter(todayStart) && n.decision == 'sent'
    );
    
    if (todayNudges.isNotEmpty) {
      return true;
    }

    // Suppress after 3 ignored in 7 days
    final ignoredCount = nudges.where(
      (n) => n.userAction == 'ignored'
    ).length;
    
    if (ignoredCount >= 3) {
      return true;
    }

    return false;
  }

  Future<void> sendNudge({
    required UserProfile profile,
    required int calorieOverage,
    required int stepDeficit,
  }) async {
    final behaviorProfile = await _db.getBehaviorProfile();
    final tone = _learningEngine.getMessageTone(behaviorProfile);
    
    String title;
    String body;

    switch (tone) {
      case 'encouraging':
        title = '🌟 You\'re doing great!';
        body = 'A quick ${stepDeficit} step walk will keep your streak going!';
        break;
      case 'gentle':
        title = '🚶 Small steps matter';
        body = 'Even a short walk of ${stepDeficit} steps helps balance today.';
        break;
      default:
        title = '📊 Movement suggestion';
        body = 'Consider a walk: ${stepDeficit} steps to stay on track.';
    }

    // Send notification
    const androidDetails = AndroidNotificationDetails(
      'nudge_channel',
      'Movement Nudges',
      channelDescription: 'Smart evening movement suggestions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      details,
      payload: 'nudge_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Log nudge
    await _logNudge(
      decision: 'sent',
      calorieOverage: calorieOverage,
      stepDeficit: stepDeficit,
    );
  }

  Future<void> _logNudge({
    required String decision,
    required int calorieOverage,
    required int stepDeficit,
  }) async {
    final nudge = NudgeLog(
      id: _uuid.v4(),
      date: DateTime.now(),
      decision: decision,
      userAction: 'pending',
      calorieOverage: calorieOverage,
      stepDeficit: stepDeficit,
      createdAt: DateTime.now(),
    );

    await _db.saveNudgeLog(nudge);
  }

  Future<void> scheduleNudgeCheck() async {
    // Schedule daily check at 8 PM
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);
    
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1,
      'Daily Check',
      'Checking your progress...',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'background_channel',
          'Background Tasks',
          channelDescription: 'Background processing',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNudges() async {
    await _notifications.cancelAll();
  }

  // User feedback
  Future<void> recordNudgeAction(String action) async {
    // Update the most recent pending nudge
    final nudges = await _db.getNudgeLogs(1);
    if (nudges.isNotEmpty) {
      // In production, would update the nudge record
      // For now, just create new log
      final latestNudge = nudges.first;
      await _db.saveNudgeLog(
        NudgeLog(
          id: latestNudge.id,
          date: latestNudge.date,
          decision: latestNudge.decision,
          userAction: action,
          calorieOverage: latestNudge.calorieOverage,
          stepDeficit: latestNudge.stepDeficit,
          createdAt: latestNudge.createdAt,
        ),
      );
    }
  }
}
