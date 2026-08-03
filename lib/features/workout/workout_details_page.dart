import 'package:flutter/material.dart';

import '../../shared/models/exercise.dart';
import '../../shared/models/workout.dart';
import '../exercise/exercise_details_page.dart';
import '../exercise/new_exercise_page.dart';
import 'pages/workout_execution_page.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final Workout workout;
  final ValueChanged<Workout> onWorkoutChanged;

  const WorkoutDetailsPage({
    super.key,
    required this.workout,
    required this.onWorkoutChanged,
  });

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  late Workout _workout;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
  }

  Future<void> _addExercise() async {
    final exercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NewExercisePage(initialOrder: _workout.exercises.length + 1),
      ),
    );
    if (exercise == null) return;

    final exercises = [..._workout.exercises, exercise]
      ..sort((first, second) => first.order.compareTo(second.order));
    _updateWorkout(exercises);
  }

  Future<void> _openExercise(int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailsPage(
          exercise: _workout.exercises[index],
          onExerciseChanged: (exercise) {
            final exercises = [..._workout.exercises];
            exercises[index] = exercise;
            _updateWorkout(exercises);
          },
        ),
      ),
    );
  }

  void _updateWorkout(List<Exercise> exercises) {
    setState(() => _workout = _workout.copyWith(exercises: exercises));
    widget.onWorkoutChanged(_workout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_workout.name)),
      body: _workout.exercises.isEmpty
          ? const Center(
              child: Text('Nenhum exercício cadastrado neste treino.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _workout.exercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final exercise = _workout.exercises[index];
                final seriesLabel = exercise.sets.length == 1
                    ? '1 série'
                    : '${exercise.sets.length} séries';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${exercise.order}')),
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.muscleGroup} • $seriesLabel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openExercise(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _workout.exercises.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutExecutionPage(workout: _workout),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Iniciar Treino', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
