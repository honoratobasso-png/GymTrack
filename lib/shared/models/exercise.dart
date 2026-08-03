import '../services/id_generator.dart';
import 'exercise_prescription.dart';
import 'exercise_set.dart';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String? notes;
  final int order;
  final ExercisePrescription? prescription;
  final List<ExerciseSet> sets;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;
  final String? deviceId;
  final String? userId;
  final bool isArchived;
  final DateTime? archivedAt;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.prescription,
    this.sets = const [],
    this.schemaVersion = 1,
    this.deviceId,
    this.userId,
    this.isArchived = false,
    this.archivedAt,
  });

  factory Exercise.create({
    required String name,
    required String muscleGroup,
    required int order,
    String? notes,
    required ExercisePrescription prescription,
  }) {
    final now = DateTime.now().toUtc();
    return Exercise(
      id: IdGenerator.generate(),
      name: name,
      muscleGroup: muscleGroup,
      order: order,
      notes: notes,
      prescription: prescription,
      createdAt: now,
      updatedAt: now,
      sets: List.generate(
        prescription.setCount,
        (index) => ExerciseSet.create(
          order: index + 1,
          repetitions: prescription.repetitions,
          weight: prescription.weight,
          restSeconds: prescription.restSeconds,
        ),
      ),
    );
  }

  Exercise copyWith({
    List<ExerciseSet>? sets,
    ExercisePrescription? prescription,
    String? name,
    String? notes,
  }) => Exercise(
    id: id,
    name: name ?? this.name,
    muscleGroup: muscleGroup,
    notes: notes ?? this.notes,
    order: order,
    prescription: prescription ?? this.prescription,
    sets: sets ?? this.sets,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    schemaVersion: schemaVersion,
    deviceId: deviceId,
    userId: userId,
    isArchived: isArchived,
    archivedAt: archivedAt,
  );

  Exercise archive() {
    final now = DateTime.now().toUtc();
    return Exercise(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      notes: notes,
      order: order,
      prescription: prescription,
      sets: sets,
      createdAt: createdAt,
      updatedAt: now,
      schemaVersion: schemaVersion,
      deviceId: deviceId,
      userId: userId,
      isArchived: true,
      archivedAt: now,
    );
  }

  Exercise restore() => Exercise(
    id: id,
    name: name,
    muscleGroup: muscleGroup,
    notes: notes,
    order: order,
    prescription: prescription,
    sets: sets,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    schemaVersion: schemaVersion,
    deviceId: deviceId,
    userId: userId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup,
    'notes': notes,
    'order': order,
    'prescription': prescription?.toJson(),
    'sets': sets.map((set) => set.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'schemaVersion': schemaVersion,
    'deviceId': deviceId,
    'userId': userId,
    'isArchived': isArchived,
    'archivedAt': archivedAt?.toIso8601String(),
  };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      notes: json['notes'] as String?,
      order: json['order'] as int,
      prescription: json['prescription'] == null
          ? null
          : ExercisePrescription.fromJson(
              json['prescription'] as Map<String, dynamic>,
            ),
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((item) => ExerciseSet.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? now
          : DateTime.parse(json['createdAt'] as String).toUtc(),
      updatedAt: json['updatedAt'] == null
          ? now
          : DateTime.parse(json['updatedAt'] as String).toUtc(),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      deviceId: json['deviceId'] as String?,
      userId: json['userId'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String).toUtc(),
    );
  }
}
