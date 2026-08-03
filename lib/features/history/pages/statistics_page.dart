import 'package:flutter/material.dart';
import '../../../shared/models/workout_history_entry.dart';
import '../history_repository.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final HistoryRepository _repository = HistoryRepository();
  List<WorkoutHistoryEntry>? _history;

  int _totalTimeSeconds = 0;
  int _daysTrained = 0;
  String _favoriteWorkout = '-';
  final Map<String, int> _workoutsPerWeek = {}; // Week key -> Count

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _repository.getHistory();
    _calculateStats(history);
    setState(() {
      _history = history;
    });
  }

  void _calculateStats(List<WorkoutHistoryEntry> history) {
    if (history.isEmpty) return;

    final Set<String> uniqueDays = {};
    final Map<String, int> workoutCounts = {};

    for (var entry in history) {
      _totalTimeSeconds += entry.durationSeconds;
      
      // Count unique days
      final dateKey = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      uniqueDays.add(dateKey);

      // Count favorite workout
      workoutCounts[entry.workoutName] = (workoutCounts[entry.workoutName] ?? 0) + 1;

      // Evolution (Group by week-year for a simple bar chart concept)
      final weekYear = '${_getWeekOfYear(entry.date)}-${entry.date.year}';
      _workoutsPerWeek[weekYear] = (_workoutsPerWeek[weekYear] ?? 0) + 1;
    }

    _daysTrained = uniqueDays.length;

    // Find favorite
    int maxCount = 0;
    workoutCounts.forEach((name, count) {
      if (count > maxCount) {
        maxCount = count;
        _favoriteWorkout = name;
      }
    });
  }

  // Very simple week of year calculation
  int _getWeekOfYear(DateTime date) {
    final dayOfYear = int.parse(date.difference(DateTime(date.year, 1, 1)).inDays.toString());
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_history == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history!.isEmpty) {
      return const Center(child: Text('Nenhum dado estatístico disponível.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildStatCard('Dias Treinados', '$_daysTrained dias', Icons.calendar_today),
            _buildStatCard('Tempo Total', _formatDuration(_totalTimeSeconds), Icons.timer),
            _buildStatCard('Treino Favorito', _favoriteWorkout, Icons.favorite),
            _buildStatCard('Total de Treinos', '${_history!.length}', Icons.fitness_center),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Evolução (Treinos por Semana)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildEvolutionChart(),
      ],
    );
  }

  Widget _buildEvolutionChart() {
    if (_workoutsPerWeek.isEmpty) return const SizedBox.shrink();

    // Take the last 5 weeks
    final keys = _workoutsPerWeek.keys.toList().reversed.take(5).toList().reversed.toList();

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: keys.map((key) {
          final count = _workoutsPerWeek[key]!;
          // Find max for scaling
          final maxCount = _workoutsPerWeek.values.reduce((a, b) => a > b ? a : b);
          final heightFactor = maxCount == 0 ? 0.0 : count / maxCount;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$count', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 100 * heightFactor,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text('Sem $key'.split('-').first, style: const TextStyle(fontSize: 10)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
