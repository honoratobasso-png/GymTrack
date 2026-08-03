import 'package:flutter/material.dart';

import '../../shared/models/workout.dart';
import '../../shared/repositories/workout_repository.dart';
import '../../shared/widgets/animated_list_item.dart';
import '../history/pages/history_page.dart';
import '../history/pages/statistics_page.dart';
import '../settings/settings_page.dart';
import '../workout/new_workout_page.dart';
import '../workout/workout_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _repository = WorkoutRepository();
  List<Workout> _workouts = [];
  var _isLoading = true;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await _repository.getActive();
    if (!mounted) return;
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  Future<void> _newWorkout() async {
    final workout = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(builder: (_) => const NewWorkoutPage()),
    );
    if (workout == null) return;
    await _repository.insert(workout);
    if (mounted) setState(() => _workouts = [..._workouts, workout]);
  }

  Future<void> _openWorkout(int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsPage(
          workout: _workouts[index],
          onWorkoutChanged: (workout) => _replaceWorkout(index, workout),
        ),
      ),
    );
  }

  Future<void> _replaceWorkout(int index, Workout workout) async {
    await _repository.update(workout);
    if (!mounted) return;
    final updated = [..._workouts]..[index] = workout;
    setState(() => _workouts = updated);
  }

  Future<void> _editWorkout(int index) async {
    final edited = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(
        builder: (_) => NewWorkoutPage(workout: _workouts[index]),
      ),
    );
    if (edited != null) await _replaceWorkout(index, edited);
  }

  Future<void> _archiveWorkout(int index) async {
    final workout = _workouts[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar treino?'),
        content: Text(
          'O treino "${workout.name}" deixará a lista ativa, mas seus dados serão preservados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.archive(workout.id);
    if (mounted) setState(() => _workouts = [..._workouts]..removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildWorkoutsTab(),
      const HistoryPage(),
      const StatisticsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0 ? const Text('Meus treinos') : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _newWorkout,
              icon: const Icon(Icons.add),
              label: const Text('Novo treino'),
            )
          : null,
    );
  }

  Widget _buildWorkoutsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_workouts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 64),
            SizedBox(height: 16),
            Text('Nenhum treino cadastrado', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Toque em + para criar o primeiro.'),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _workouts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final workout = _workouts[index];
        final exerciseLabel = workout.exercises.length == 1
            ? '1 exercício'
            : '${workout.exercises.length} exercícios';
        return AnimatedListItem(
          index: index,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
                child: const Icon(Icons.fitness_center),
              ),
              title: Text(
                workout.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                workout.description == null || workout.description!.isEmpty
                    ? exerciseLabel
                    : '${workout.description}\n$exerciseLabel',
              ),
              isThreeLine:
                  workout.description != null &&
                  workout.description!.isNotEmpty,
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    _editWorkout(index);
                  }
                  if (action == 'archive') {
                    _archiveWorkout(index);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar treino')),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text('Arquivar treino'),
                  ),
                ],
              ),
              onTap: () => _openWorkout(index),
            ),
          ),
        );
      },
    );
  }
}
