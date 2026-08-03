import 'package:flutter/material.dart';

import '../../shared/models/exercise.dart';
import '../../shared/models/exercise_set.dart';
import 'new_exercise_set_page.dart';

class ExerciseDetailsPage extends StatefulWidget {
  final Exercise exercise;
  final ValueChanged<Exercise> onExerciseChanged;

  const ExerciseDetailsPage({
    super.key,
    required this.exercise,
    required this.onExerciseChanged,
  });

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  late Exercise _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = widget.exercise;
  }

  Future<void> _addSet() async {
    final set = await Navigator.push<ExerciseSet>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NewExerciseSetPage(initialOrder: _exercise.sets.length + 1),
      ),
    );
    if (set == null) return;

    setState(
      () => _exercise = _exercise.copyWith(sets: [..._exercise.sets, set]),
    );
    widget.onExerciseChanged(_exercise);
  }

  String _setSummary(ExerciseSet set) {
    final details = ['${set.repetitions} repetições'];
    if (set.weight != null) details.add('${set.weight} kg');
    if (set.durationSeconds != null) details.add('${set.durationSeconds} s');
    return details.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_exercise.name)),
      body: _exercise.sets.isEmpty
          ? const Center(
              child: Text('Nenhuma série cadastrada neste exercício.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _exercise.sets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final set = _exercise.sets[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${set.order}')),
                    title: Text('Série ${set.order}'),
                    subtitle: Text(_setSummary(set)),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSet,
        icon: const Icon(Icons.add),
        label: const Text('Nova série'),
      ),
    );
  }
}
