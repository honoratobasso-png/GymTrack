import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/repositories/settings_repository.dart';
import '../../../shared/repositories/workout_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settings = SettingsRepository();
  final _workoutRepository = WorkoutRepository();

  static const _restOptions = [30, 45, 60, 90, 120];

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
    }
  }

  Future<void> _exportBackup() async {
    try {
      final workouts = await _workoutRepository.getActive();
      final json = JsonEncoder.withIndent(
        '  ',
      ).convert(workouts.map((w) => w.toJson()).toList());
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup copiado para a área de transferência!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          // --- Tema ---
          _SectionHeader(title: 'Aparência'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            trailing: DropdownButton<ThemeMode>(
              value: _settings.themeMode,
              underline: const SizedBox.shrink(),
              items: ThemeMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(_themeModeLabel(mode)),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) _settings.setThemeMode(mode);
                setState(() {});
              },
            ),
          ),

          const Divider(),

          // --- Descanso padrão ---
          _SectionHeader(title: 'Treino'),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Descanso padrão'),
            trailing: DropdownButton<int>(
              value: _restOptions.contains(_settings.defaultRestSeconds)
                  ? _settings.defaultRestSeconds
                  : 60,
              underline: const SizedBox.shrink(),
              items: _restOptions.map((s) {
                final label = s < 60
                    ? '${s}s'
                    : s % 60 == 0
                    ? '${s ~/ 60}min'
                    : '${s ~/ 60}min ${s % 60}s';
                return DropdownMenuItem(value: s, child: Text(label));
              }).toList(),
              onChanged: (val) {
                if (val != null) _settings.setDefaultRestSeconds(val);
                setState(() {});
              },
            ),
          ),

          const Divider(),

          // --- Backup ---
          _SectionHeader(title: 'Dados'),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Exportar Backup'),
            subtitle: const Text(
              'Copia os treinos como JSON para a área de transferência',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportBackup,
          ),

          const Divider(),

          // --- Sobre ---
          _SectionHeader(title: 'Sobre'),
          const ListTile(
            leading: Icon(Icons.info_outlined),
            title: Text('GymTrack'),
            subtitle: Text('Versão 1.0.0 • Sprint 14'),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Idioma'),
            subtitle: Text('Português (BR)'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
