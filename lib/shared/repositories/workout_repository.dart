import '../models/workout.dart';
import '../services/workout_storage.dart';

/// Fachada de dados usada pelas telas; oculta os detalhes do SQLite.
class WorkoutRepository {
  final WorkoutStorage _storage;

  WorkoutRepository({WorkoutStorage? storage})
    : _storage = storage ?? WorkoutStorage();

  Future<List<Workout>> getActive() => _storage.load();
  Future<List<Workout>> getAll() => _storage.load(includeArchived: true);
  Future<void> insert(Workout workout) => _storage.insert(workout);
  Future<void> update(Workout workout) => _storage.update(workout);
  Future<void> archive(String workoutId) => _storage.archiveWorkout(workoutId);
  Future<void> restore(String workoutId) => _storage.restoreWorkout(workoutId);
  Future<void> archiveExercise(String exerciseId) =>
      _storage.archiveExercise(exerciseId);
  Future<void> restoreExercise(String exerciseId) =>
      _storage.restoreExercise(exerciseId);
}
