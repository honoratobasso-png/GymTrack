import '../services/id_generator.dart';

/// Uma série gerada por uma prescrição; seus valores podem ser editados isoladamente.
class ExerciseSet {
  final String id;
  final int order;
  final int repetitions;
  final double? weight;
  final int restSeconds;
  final int? durationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final String? deviceId;
  final String? userId;

  const ExerciseSet({
    required this.id,
    required this.order,
    required this.repetitions,
    required this.restSeconds,
    required this.createdAt,
    required this.updatedAt,
    this.weight,
    this.durationSeconds,
    this.schemaVersion = 1,
    this.deviceId,
    this.userId,
  });

  factory ExerciseSet.create({
    required int order,
    required int repetitions,
    double? weight,
    required int restSeconds,
    int? durationSeconds,
  }) {
    final now = DateTime.now().toUtc();
    return ExerciseSet(
      id: IdGenerator.generate(),
      order: order,
      repetitions: repetitions,
      weight: weight,
      restSeconds: restSeconds,
      durationSeconds: durationSeconds,
      createdAt: now,
      updatedAt: now,
    );
  }

  ExerciseSet copyWith({
    int? repetitions,
    double? weight,
    int? restSeconds,
    int? durationSeconds,
  }) => ExerciseSet(
    id: id,
    order: order,
    repetitions: repetitions ?? this.repetitions,
    weight: weight ?? this.weight,
    restSeconds: restSeconds ?? this.restSeconds,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    schemaVersion: schemaVersion,
    deviceId: deviceId,
    userId: userId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'repetitions': repetitions,
    'weight': weight,
    'restSeconds': restSeconds,
    'durationSeconds': durationSeconds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'schemaVersion': schemaVersion,
    'deviceId': deviceId,
    'userId': userId,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    return ExerciseSet(
      id: json['id'] as String,
      order: json['order'] as int? ?? 1,
      repetitions: json['repetitions'] as int,
      weight: (json['weight'] as num?)?.toDouble(),
      restSeconds: json['restSeconds'] as int? ?? 60,
      durationSeconds: json['durationSeconds'] as int?,
      createdAt: json['createdAt'] == null
          ? now
          : DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: json['updatedAt'] == null
          ? now
          : DateTime.parse(json['updatedAt'] as String).toUtc(),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      deviceId: json['deviceId'] as String?,
      userId: json['userId'] as String?,
    );
  }
}
