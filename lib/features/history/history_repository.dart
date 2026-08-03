import 'package:sqflite/sqflite.dart';

import '../../shared/models/workout_history_entry.dart';
import '../../shared/services/database_service.dart';

/// Repositório do histórico; a UI não acessa o banco diretamente.
class HistoryRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<List<WorkoutHistoryEntry>> getHistory() async {
    final db = await _dbService.db;
    final maps = await db.query('workout_history', orderBy: 'date DESC');
    return maps.map((map) => WorkoutHistoryEntry.fromMap(map)).toList();
  }

  Future<void> saveEntry(WorkoutHistoryEntry entry) async {
    final db = await _dbService.db;
    await db.insert(
      'workout_history',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
