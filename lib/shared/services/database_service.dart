import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Ponto único de acesso ao SQLite e às migrações versionadas do aplicativo.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _version = 3;
  Database? _db;

  Future<Database> get db async => _db ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'gymtrack.db');
    return openDatabase(
      path,
      version: _version,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE workouts (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT,
      createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, schemaVersion INTEGER NOT NULL DEFAULT 1,
      deviceId TEXT, userId TEXT, isArchived INTEGER NOT NULL DEFAULT 0, archivedAt TEXT
    )''');
    await db.execute('''CREATE TABLE exercises (
      id TEXT PRIMARY KEY, workoutId TEXT NOT NULL, name TEXT NOT NULL, muscleGroup TEXT NOT NULL,
      notes TEXT, exerciseOrder INTEGER NOT NULL, plannedSetCount INTEGER, plannedRepetitions INTEGER,
      plannedWeight REAL, plannedRestSeconds INTEGER, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL,
      schemaVersion INTEGER NOT NULL DEFAULT 1, deviceId TEXT, userId TEXT,
      isArchived INTEGER NOT NULL DEFAULT 0, archivedAt TEXT,
      FOREIGN KEY (workoutId) REFERENCES workouts(id) ON DELETE CASCADE
    )''');
    await db.execute('''CREATE TABLE exercise_sets (
      id TEXT PRIMARY KEY, exerciseId TEXT NOT NULL, setOrder INTEGER NOT NULL, repetitions INTEGER NOT NULL,
      weight REAL, restSeconds INTEGER NOT NULL DEFAULT 60, durationSeconds INTEGER,
      createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, schemaVersion INTEGER NOT NULL DEFAULT 1,
      deviceId TEXT, userId TEXT,
      FOREIGN KEY (exerciseId) REFERENCES exercises(id) ON DELETE CASCADE
    )''');
    await db.execute('''CREATE TABLE workout_history (
      id TEXT PRIMARY KEY, workoutId TEXT, workoutName TEXT NOT NULL, workoutSnapshot TEXT NOT NULL DEFAULT '{}',
      date TEXT NOT NULL, durationSeconds INTEGER NOT NULL, exercisesCompleted INTEGER NOT NULL,
      createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, schemaVersion INTEGER NOT NULL DEFAULT 1,
      deviceId TEXT, userId TEXT
    )''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumn(db, 'workouts', 'updatedAt TEXT');
      await _addColumn(
        db,
        'workouts',
        'schemaVersion INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumn(db, 'workouts', 'deviceId TEXT');
      await _addColumn(db, 'workouts', 'userId TEXT');
      await _addColumn(db, 'workouts', 'isArchived INTEGER NOT NULL DEFAULT 0');
      await _addColumn(db, 'workouts', 'archivedAt TEXT');
      await _addColumn(db, 'exercises', 'createdAt TEXT');
      await _addColumn(db, 'exercises', 'updatedAt TEXT');
      await _addColumn(
        db,
        'exercises',
        'schemaVersion INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumn(db, 'exercises', 'deviceId TEXT');
      await _addColumn(db, 'exercises', 'userId TEXT');
      await _addColumn(
        db,
        'exercises',
        'isArchived INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumn(db, 'exercises', 'archivedAt TEXT');
      await _addColumn(db, 'exercise_sets', 'createdAt TEXT');
      await _addColumn(db, 'exercise_sets', 'updatedAt TEXT');
      await _addColumn(
        db,
        'exercise_sets',
        'schemaVersion INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumn(db, 'exercise_sets', 'deviceId TEXT');
      await _addColumn(db, 'exercise_sets', 'userId TEXT');
      await _addColumn(db, 'workout_history', 'workoutId TEXT');
      await _addColumn(
        db,
        'workout_history',
        "workoutSnapshot TEXT NOT NULL DEFAULT '{}'",
      );
      await _addColumn(db, 'workout_history', 'createdAt TEXT');
      await _addColumn(db, 'workout_history', 'updatedAt TEXT');
      await _addColumn(
        db,
        'workout_history',
        'schemaVersion INTEGER NOT NULL DEFAULT 1',
      );
      await _addColumn(db, 'workout_history', 'deviceId TEXT');
      await _addColumn(db, 'workout_history', 'userId TEXT');
      final now = DateTime.now().toUtc().toIso8601String();
      await db.execute(
        "UPDATE workouts SET updatedAt = COALESCE(updatedAt, createdAt)",
      );
      await db.execute(
        "UPDATE exercises SET createdAt = COALESCE(createdAt, '$now'), updatedAt = COALESCE(updatedAt, '$now')",
      );
      await db.execute(
        "UPDATE exercise_sets SET createdAt = COALESCE(createdAt, '$now'), updatedAt = COALESCE(updatedAt, '$now')",
      );
      await db.execute(
        "UPDATE workout_history SET createdAt = COALESCE(createdAt, date), updatedAt = COALESCE(updatedAt, date)",
      );
    }
    if (oldVersion < 3) {
      await _addColumn(db, 'exercises', 'plannedSetCount INTEGER');
      await _addColumn(db, 'exercises', 'plannedRepetitions INTEGER');
      await _addColumn(db, 'exercises', 'plannedWeight REAL');
      await _addColumn(db, 'exercises', 'plannedRestSeconds INTEGER');
      await _addColumn(
        db,
        'exercise_sets',
        'restSeconds INTEGER NOT NULL DEFAULT 60',
      );
    }
  }

  Future<void> _addColumn(Database db, String table, String definition) async {
    final column = definition.split(' ').first;
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    if (columns.any((item) => item['name'] == column)) return;
    await db.execute('ALTER TABLE $table ADD COLUMN $definition');
  }
}
