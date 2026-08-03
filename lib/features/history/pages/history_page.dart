import 'package:flutter/material.dart';
import '../../../shared/models/workout_history_entry.dart';
import '../history_repository.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryRepository _repository = HistoryRepository();
  List<WorkoutHistoryEntry>? _history;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.getHistory();
    setState(() {
      _history = history;
    });
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '$m min ${s > 0 ? '$s s' : ''}';
    }
    return '$s s';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_history == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history!.isEmpty) {
      return const Center(
        child: Text('Nenhum treino realizado ainda.\nBora treinar!'),
      );
    }

    return ListView.builder(
      itemCount: _history!.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final entry = _history![index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.fitness_center),
            ),
            title: Text(entry.workoutName),
            subtitle: Text(_formatDate(entry.date)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDuration(entry.durationSeconds),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${entry.exercisesCompleted} exércicios', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
