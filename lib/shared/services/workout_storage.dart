import '../models/exercise.dart';
import '../models/exercise_prescription.dart';
import '../models/exercise_set.dart';
import '../models/workout.dart';
import 'database_service.dart';
import 'package:sqflite/sqflite.dart';

/// Persistência incremental do grafo de treinos. Nunca remove dados ativos.
class WorkoutStorage {
  final DatabaseService _dbService = DatabaseService();

  Future<List<Workout>> load({bool includeArchived = false}) async {
    final db = await _dbService.db;
    final workoutMaps = await db.query(
      'workouts',
      where: includeArchived ? null : 'isArchived = 0',
      orderBy: 'createdAt ASC',
    );
    final workouts = <Workout>[];
    for (final workoutMap in workoutMaps) {
      final workoutId = workoutMap['id'] as String;
      final exerciseMaps = await db.query(
        'exercises',
        where: includeArchived
            ? 'workoutId = ?'
            : 'workoutId = ? AND isArchived = 0',
        whereArgs: [workoutId],
        orderBy: 'exerciseOrder ASC',
      );
      final exercises = <Exercise>[];
      for (final exerciseMap in exerciseMaps) {
        final exerciseId = exerciseMap['id'] as String;
        final setMaps = await db.query(
          'exercise_sets',
          where: 'exerciseId = ?',
          whereArgs: [exerciseId],
          orderBy: 'setOrder ASC',
        );
        final sets = setMaps.map(_toSet).toList();
        exercises.add(_toExercise(exerciseMap, sets));
      }
      workouts.add(_toWorkout(workoutMap, exercises));
    }
    return workouts;
  }

  Future<void> insert(Workout workout) async {
    final db = await _dbService.db;
    await db.transaction((txn) => _persistGraph(txn, workout));
  }

  Future<void> update(Workout workout) async {
    final db = await _dbService.db;
    await db.transaction((txn) => _persistGraph(txn, workout));
  }

  Future<void> archiveWorkout(String id) => _setArchive('workouts', id, true);
  Future<void> restoreWorkout(String id) => _setArchive('workouts', id, false);
  Future<void> archiveExercise(String id) => _setArchive('exercises', id, true);
  Future<void> restoreExercise(String id) =>
      _setArchive('exercises', id, false);

  /// Limpeza física futura, nunca exposta pela interface do usuário.
  Future<int> purgeArchivedBefore(DateTime before) async {
    final db = await _dbService.db;
    return db.delete(
      'workouts',
      where: 'isArchived = 1 AND archivedAt < ?',
      whereArgs: [before.toUtc().toIso8601String()],
    );
  }

  Future<void> _setArchive(String table, String id, bool archived) async {
    final db = await _dbService.db;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.update(
      table,
      {
        'isArchived': archived ? 1 : 0,
        'archivedAt': archived ? now : null,
        'updatedAt': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> _persistGraph(DatabaseExecutor executor, Workout workout) async {
    await _upsert(executor, 'workouts', _workoutValues(workout));
    for (final exercise in workout.exercises) {
      await _upsert(
        executor,
        'exercises',
        _exerciseValues(workout.id, exercise),
      );
      for (final set in exercise.sets) {
        await _upsert(executor, 'exercise_sets', _setValues(exercise.id, set));
      }
    }
  }

  Future<void> _upsert(
    DatabaseExecutor executor,
    String table,
    Map<String, Object?> values,
  ) async {
    final count = await executor.update(
      table,
      values,
      where: 'id = ?',
      whereArgs: [values['id']],
    );
    if (count == 0) await executor.insert(table, values);
  }

  Map<String, Object?> _workoutValues(Workout item) => {
    'id': item.id,
    'name': item.name,
    'description': item.description,
    'createdAt': item.createdAt.toIso8601String(),
    'updatedAt': item.updatedAt.toIso8601String(),
    'schemaVersion': item.schemaVersion,
    'deviceId': item.deviceId,
    'userId': item.userId,
    'isArchived': item.isArchived ? 1 : 0,
    'archivedAt': item.archivedAt?.toIso8601String(),
  };

  Map<String, Object?> _exerciseValues(String workoutId, Exercise item) => {
    'id': item.id,
    'workoutId': workoutId,
    'name': item.name,
    'muscleGroup': item.muscleGroup,
    'notes': item.notes,
    'exerciseOrder': item.order,
    'plannedSetCount': item.prescription?.setCount,
    'plannedRepetitions': item.prescription?.repetitions,
    'plannedWeight': item.prescription?.weight,
    'plannedRestSeconds': item.prescription?.restSeconds,
    'createdAt': item.createdAt.toIso8601String(),
    'updatedAt': item.updatedAt.toIso8601String(),
    'schemaVersion': item.schemaVersion,
    'deviceId': item.deviceId,
    'userId': item.userId,
    'isArchived': item.isArchived ? 1 : 0,
    'archivedAt': item.archivedAt?.toIso8601String(),
  };

  Map<String, Object?> _setValues(String exerciseId, ExerciseSet item) => {
    'id': item.id,
    'exerciseId': exerciseId,
    'setOrder': item.order,
    'repetitions': item.repetitions,
    'weight': item.weight,
    'restSeconds': item.restSeconds,
    'durationSeconds': item.durationSeconds,
    'createdAt': item.createdAt.toIso8601String(),
    'updatedAt': item.updatedAt.toIso8601String(),
    'schemaVersion': item.schemaVersion,
    'deviceId': item.deviceId,
    'userId': item.userId,
  };

  Workout _toWorkout(Map<String, Object?> map, List<Exercise> exercises) =>
      Workout(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String).toUtc(),
        updatedAt: DateTime.parse(
          map['updatedAt'] as String? ?? map['createdAt'] as String,
        ).toUtc(),
        schemaVersion: map['schemaVersion'] as int? ?? 1,
        deviceId: map['deviceId'] as String?,
        userId: map['userId'] as String?,
        isArchived: (map['isArchived'] as int? ?? 0) == 1,
        archivedAt: map['archivedAt'] == null
            ? null
            : DateTime.parse(map['archivedAt'] as String).toUtc(),
        exercises: exercises,
      );

  Exercise _toExercise(Map<String, Object?> map, List<ExerciseSet> sets) {
    final count = map['plannedSetCount'] as int?;
    final repetitions = map['plannedRepetitions'] as int?;
    final restSeconds = map['plannedRestSeconds'] as int?;
    final prescription =
        count == null || repetitions == null || restSeconds == null
        ? null
        : ExercisePrescription(
            setCount: count,
            repetitions: repetitions,
            weight: (map['plannedWeight'] as num?)?.toDouble(),
            restSeconds: restSeconds,
          );
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      notes: map['notes'] as String?,
      order: map['exerciseOrder'] as int,
      prescription: prescription,
      sets: sets,
      createdAt: DateTime.parse(map['createdAt'] as String).toUtc(),
      updatedAt: DateTime.parse(map['updatedAt'] as String).toUtc(),
      schemaVersion: map['schemaVersion'] as int? ?? 1,
      deviceId: map['deviceId'] as String?,
      userId: map['userId'] as String?,
      isArchived: (map['isArchived'] as int? ?? 0) == 1,
      archivedAt: map['archivedAt'] == null
          ? null
          : DateTime.parse(map['archivedAt'] as String).toUtc(),
    );
  }

  ExerciseSet _toSet(Map<String, Object?> map) => ExerciseSet(
    id: map['id'] as String,
    order: map['setOrder'] as int,
    repetitions: map['repetitions'] as int,
    weight: (map['weight'] as num?)?.toDouble(),
    restSeconds: map['restSeconds'] as int? ?? 60,
    durationSeconds: map['durationSeconds'] as int?,
    createdAt: DateTime.parse(map['createdAt'] as String).toUtc(),
    updatedAt: DateTime.parse(map['updatedAt'] as String).toUtc(),
    schemaVersion: map['schemaVersion'] as int? ?? 1,
    deviceId: map['deviceId'] as String?,
    userId: map['userId'] as String?,
  );
}
