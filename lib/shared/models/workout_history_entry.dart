import 'dart:convert';

import '../services/id_generator.dart';
import 'workout.dart';

/// Registro imutável de uma sessão concluída; preserva o contexto do treino na data da execução.
class WorkoutHistoryEntry {
  final String id;
  final String? workoutId;
  final String workoutName;
  final Map<String, dynamic> workoutSnapshot;
  final DateTime date;
  final int durationSeconds;
  final int exercisesCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final String? deviceId;
  final String? userId;

  const WorkoutHistoryEntry({
    required this.id,
    required this.workoutId,
    required this.workoutName,
    required this.workoutSnapshot,
    required this.date,
    required this.durationSeconds,
    required this.exercisesCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.schemaVersion = 1,
    this.deviceId,
    this.userId,
  });

  factory WorkoutHistoryEntry.fromWorkout({
    required Workout workout,
    required DateTime date,
    required int durationSeconds,
    required int exercisesCompleted,
  }) {
    final now = date.toUtc();
    return WorkoutHistoryEntry(
      id: IdGenerator.generate(),
      workoutId: workout.id,
      workoutName: workout.name,
      workoutSnapshot: {
        'workoutId': workout.id,
        'name': workout.name,
        'exerciseCount': workout.exercises.length,
      },
      date: now,
      durationSeconds: durationSeconds,
      exercisesCompleted: exercisesCompleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'workoutId': workoutId,
    'workoutName': workoutName,
    'workoutSnapshot': jsonEncode(workoutSnapshot),
    'date': date.toIso8601String(),
    'durationSeconds': durationSeconds,
    'exercisesCompleted': exercisesCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'schemaVersion': schemaVersion,
    'deviceId': deviceId,
    'userId': userId,
  };

  factory WorkoutHistoryEntry.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['date'] as String).toUtc();
    final rawSnapshot = map['workoutSnapshot'] as String?;
    return WorkoutHistoryEntry(
      id: map['id'] as String,
      workoutId: map['workoutId'] as String?,
      workoutName: map['workoutName'] as String,
      workoutSnapshot: rawSnapshot == null || rawSnapshot.isEmpty
          ? {'name': map['workoutName']}
          : jsonDecode(rawSnapshot) as Map<String, dynamic>,
      date: date,
      durationSeconds: (map['durationSeconds'] as num).toInt(),
      exercisesCompleted: (map['exercisesCompleted'] as num).toInt(),
      createdAt: map['createdAt'] == null
          ? date
          : DateTime.parse(map['createdAt'] as String).toUtc(),
      updatedAt: map['updatedAt'] == null
          ? date
          : DateTime.parse(map['updatedAt'] as String).toUtc(),
      schemaVersion: map['schemaVersion'] as int? ?? 1,
      deviceId: map['deviceId'] as String?,
      userId: map['userId'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WorkoutHistoryEntry.fromJson(String source) =>
      WorkoutHistoryEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
