import '../services/id_generator.dart';
import 'exercise.dart';

class Workout {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final String? deviceId;
  final String? userId;
  final bool isArchived;
  final DateTime? archivedAt;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.schemaVersion = 1,
    this.deviceId,
    this.userId,
    this.isArchived = false,
    this.archivedAt,
    this.exercises = const [],
  });

  factory Workout.create({required String name, String? description}) {
    final now = DateTime.now().toUtc();
    return Workout(
      id: IdGenerator.generate(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  Workout copyWith({
    String? name,
    String? description,
    List<Exercise>? exercises,
    DateTime? updatedAt,
  }) => Workout(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now().toUtc(),
    schemaVersion: schemaVersion,
    deviceId: deviceId,
    userId: userId,
    isArchived: isArchived,
    archivedAt: archivedAt,
    exercises: exercises ?? this.exercises,
  );

  Workout archive() {
    final now = DateTime.now().toUtc();
    return Workout(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: now,
      schemaVersion: schemaVersion,
      deviceId: deviceId,
      userId: userId,
      isArchived: true,
      archivedAt: now,
      exercises: exercises,
    );
  }

  Workout restore() => Workout(
    id: id,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    schemaVersion: schemaVersion,
    deviceId: deviceId,
    userId: userId,
    exercises: exercises,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'schemaVersion': schemaVersion,
    'deviceId': deviceId,
    'userId': userId,
    'isArchived': isArchived,
    'archivedAt': archivedAt?.toIso8601String(),
    'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String).toUtc();
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: createdAt,
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? createdAt.toIso8601String(),
      ).toUtc(),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      deviceId: json['deviceId'] as String?,
      userId: json['userId'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String).toUtc(),
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
