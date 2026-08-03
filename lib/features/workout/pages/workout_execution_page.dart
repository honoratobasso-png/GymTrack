import 'package:flutter/material.dart';

import '../../../shared/models/workout.dart';
import '../controllers/workout_execution_controller.dart';
import '../widgets/rest_timer_bottom_sheet.dart';

class WorkoutExecutionPage extends StatefulWidget {
  final Workout workout;

  const WorkoutExecutionPage({super.key, required this.workout});

  @override
  State<WorkoutExecutionPage> createState() => _WorkoutExecutionPageState();
}

class _WorkoutExecutionPageState extends State<WorkoutExecutionPage> {
  late WorkoutExecutionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WorkoutExecutionController(workout: widget.workout);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {}); // Rebuild on controller change
  }

  Future<void> _finishWorkout() async {
    await _controller.finishWorkout();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Treino Concluído!'),
        content: const Text('Parabéns por finalizar mais um treino!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close execution page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isWorkoutFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Treino Finalizado')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              const Text('Muito bem!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _finishWorkout,
                child: const Text('Finalizar'),
              ),
            ],
          ),
        ),
      );
    }

    final currentExercise = _controller.currentExercise!;
    final nextExercise = _controller.nextExercise;
    final progress =
        (_controller.currentExerciseIndex /
        _controller.workout.exercises.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Ask confirmation to cancel
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cancelar treino?'),
                  content: const Text('O progresso será perdido.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // close execution page
                      },
                      child: const Text('Sim, cancelar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Exercício Atual',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentExercise.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (currentExercise.notes != null &&
                            currentExercise.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            currentExercise.notes!,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        if (currentExercise.sets.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Nenhuma série cadastrada.'),
                          ),
                        ...currentExercise.sets.map((set) {
                          final isCompleted = _controller.isSetCompleted(
                            set.id,
                          );
                          return CheckboxListTile(
                            title: Text(
                              '${set.repetitions} repetições ${set.weight != null ? " - ${set.weight} kg" : ""}',
                              style: TextStyle(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted ? Colors.grey : null,
                              ),
                            ),
                            value: isCompleted,
                            onChanged: (_) {
                              _controller.toggleSet(set.id);

                              // If checked and it's not the last set, offer to rest
                              if (!isCompleted &&
                                  !_controller.areAllCurrentSetsCompleted) {
                                RestTimerBottomSheet.show(
                                  context,
                                  initialSeconds: set.restSeconds,
                                );
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (nextExercise != null) ...[
                  Text(
                    'Próximo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: Text(nextExercise.name),
                      subtitle: Text(nextExercise.muscleGroup),
                      leading: const Icon(Icons.fitness_center),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _controller.areAllCurrentSetsCompleted
                ? () {
                    _controller.nextExerciseIfPossible();
                    if (_controller.isWorkoutFinished) {
                      _finishWorkout();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _controller.nextExercise == null
                  ? 'Finalizar Treino'
                  : 'Próximo Exercício',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
