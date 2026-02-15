import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/meal_log.dart';
import '../models/activity_log.dart';
import '../models/behavior_profile.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nutriwalk_ai.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User Profile Table
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        age INTEGER NOT NULL,
        height REAL NOT NULL,
        current_weight REAL NOT NULL,
        goal_weight REAL NOT NULL,
        activity_level TEXT NOT NULL,
        gender TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Meal Logs Table
    await db.execute('''
      CREATE TABLE meal_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        items TEXT NOT NULL,
        total_calories REAL NOT NULL,
        total_protein REAL NOT NULL,
        total_carbs REAL NOT NULL,
        total_fat REAL NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Weight Logs Table
    await db.execute('''
      CREATE TABLE weight_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Activity Logs Table
    await db.execute('''
      CREATE TABLE activity_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        distance REAL NOT NULL,
        active_minutes INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Behavior Profile Table
    await db.execute('''
      CREATE TABLE behavior_profile (
        id TEXT PRIMARY KEY,
        avg_steps_7d REAL NOT NULL,
        compliance_rate REAL NOT NULL,
        ignore_rate REAL NOT NULL,
        dynamic_step_target INTEGER NOT NULL,
        preferred_active_hour INTEGER,
        updated_at TEXT NOT NULL
      )
    ''');

    // Nudge Logs Table
    await db.execute('''
      CREATE TABLE nudge_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        decision TEXT NOT NULL,
        user_action TEXT NOT NULL,
        calorie_overage INTEGER NOT NULL,
        step_deficit INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_meal_date ON meal_logs(date)');
    await db.execute('CREATE INDEX idx_weight_date ON weight_logs(date)');
    await db.execute('CREATE INDEX idx_activity_date ON activity_logs(date)');
    await db.execute('CREATE INDEX idx_nudge_date ON nudge_logs(date)');
  }

  // User Profile Methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_profile');
    
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  // Meal Log Methods
  Future<void> saveMealLog(MealLog meal) async {
    final db = await database;
    await db.insert(
      'meal_logs',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MealLog>> getMealLogs(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
  }

  Future<List<MealLog>> getTodayMeals() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getMealLogs(startOfDay, endOfDay);
  }

  // Weight Log Methods
  Future<void> saveWeightLog(WeightLog weight) async {
    final db = await database;
    await db.insert(
      'weight_logs',
      weight.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WeightLog>> getWeightLogs(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, dynamic>> maps = await db.query(
      'weight_logs',
      where: 'date >= ?',
      whereArgs: [startDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => WeightLog.fromMap(maps[i]));
  }

  // Activity Log Methods
  Future<void> saveActivityLog(ActivityLog activity) async {
    final db = await database;
    await db.insert(
      'activity_logs',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ActivityLog?> getActivityLog(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      where: 'date = ?',
      whereArgs: [startOfDay.toIso8601String()],
    );
    
    if (maps.isEmpty) return null;
    return ActivityLog.fromMap(maps.first);
  }

  Future<List<ActivityLog>> getActivityLogs(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      where: 'date >= ?',
      whereArgs: [startDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }

  // Behavior Profile Methods
  Future<void> saveBehaviorProfile(BehaviorProfile profile) async {
    final db = await database;
    await db.insert(
      'behavior_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BehaviorProfile?> getBehaviorProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('behavior_profile');
    
    if (maps.isEmpty) return null;
    return BehaviorProfile.fromMap(maps.first);
  }

  // Nudge Log Methods
  Future<void> saveNudgeLog(NudgeLog nudge) async {
    final db = await database;
    await db.insert(
      'nudge_logs',
      nudge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NudgeLog>> getNudgeLogs(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, dynamic>> maps = await db.query(
      'nudge_logs',
      where: 'date >= ?',
      whereArgs: [startDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => NudgeLog.fromMap(maps[i]));
  }

  // Utility Methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('meal_logs');
    await db.delete('weight_logs');
    await db.delete('activity_logs');
    await db.delete('nudge_logs');
    await db.delete('behavior_profile');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
