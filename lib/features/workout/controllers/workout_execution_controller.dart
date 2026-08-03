import 'package:flutter/foundation.dart';

import '../../../shared/models/exercise.dart';
import '../../../shared/models/workout.dart';
import '../../../shared/models/workout_history_entry.dart';
import '../../history/history_repository.dart';

/// Controla o progresso de uma sessão sem alterar o treino-base.
class WorkoutExecutionController extends ChangeNotifier {
  final Workout workout;
  final HistoryRepository _historyRepository = HistoryRepository();
  final DateTime _startTime;
  final Set<String> _completedSetIds = {};
  int _currentExerciseIndex = 0;
  bool _historySaved = false;

  WorkoutExecutionController({required this.workout})
    : _startTime = DateTime.now().toUtc();

  int get currentExerciseIndex => _currentExerciseIndex;
  bool get isWorkoutFinished =>
      _currentExerciseIndex >= workout.exercises.length;
  Exercise? get currentExercise =>
      isWorkoutFinished ? null : workout.exercises[_currentExerciseIndex];
  Exercise? get nextExercise =>
      _currentExerciseIndex + 1 >= workout.exercises.length
      ? null
      : workout.exercises[_currentExerciseIndex + 1];
  bool isSetCompleted(String setId) => _completedSetIds.contains(setId);

  bool get areAllCurrentSetsCompleted {
    final exercise = currentExercise;
    return exercise != null &&
        (exercise.sets.isEmpty ||
            exercise.sets.every((set) => _completedSetIds.contains(set.id)));
  }

  int get exercisesCompleted => workout.exercises
      .where(
        (exercise) =>
            exercise.sets.isEmpty ||
            exercise.sets.every((set) => _completedSetIds.contains(set.id)),
      )
      .length;

  void toggleSet(String setId) {
    _completedSetIds.contains(setId)
        ? _completedSetIds.remove(setId)
        : _completedSetIds.add(setId);
    notifyListeners();
  }

  void nextExerciseIfPossible() {
    if (!isWorkoutFinished) {
      _currentExerciseIndex++;
      notifyListeners();
    }
  }

  Future<void> finishWorkout() async {
    if (_historySaved) return;
    _currentExerciseIndex = workout.exercises.length;
    _historySaved = true;
    final endTime = DateTime.now().toUtc();
    await _historyRepository.saveEntry(
      WorkoutHistoryEntry.fromWorkout(
        workout: workout,
        date: endTime,
        durationSeconds: endTime.difference(_startTime).inSeconds,
        exercisesCompleted: exercisesCompleted,
      ),
    );
    notifyListeners();
  }
}
