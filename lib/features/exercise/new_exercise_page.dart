import 'package:flutter/material.dart';

import '../../shared/models/exercise.dart';
import '../../shared/models/exercise_prescription.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

class NewExercisePage extends StatefulWidget {
  final int initialOrder;
  const NewExercisePage({super.key, required this.initialOrder});
  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  static const _muscleGroups = [
    'Peito',
    'Costas',
    'Ombros',
    'Bíceps',
    'Tríceps',
    'Pernas',
    'Glúteos',
    'Abdômen',
    'Cardio',
    'Outro',
  ];
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _setCountController = TextEditingController(text: '3');
  final _repetitionsController = TextEditingController(text: '12');
  final _weightController = TextEditingController();
  final _restController = TextEditingController(text: '60');
  String? _muscleGroup;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _setCountController.dispose();
    _repetitionsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    final name = _nameController.text.trim();
    final setCount = int.tryParse(_setCountController.text.trim());
    final repetitions = int.tryParse(_repetitionsController.text.trim());
    final restSeconds = int.tryParse(_restController.text.trim());
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    if (name.isEmpty ||
        _muscleGroup == null ||
        setCount == null ||
        setCount < 1 ||
        repetitions == null ||
        repetitions < 1 ||
        restSeconds == null ||
        restSeconds < 0 ||
        (weightText.isNotEmpty && (weight == null || weight < 0))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os dados da prescrição com valores válidos.'),
        ),
      );
      return;
    }
    final prescription = ExercisePrescription(
      setCount: setCount,
      repetitions: repetitions,
      weight: weight,
      restSeconds: restSeconds,
    );
    Navigator.pop(
      context,
      Exercise.create(
        name: name,
        muscleGroup: _muscleGroup!,
        order: widget.initialOrder,
        notes: _notesController.text.trim(),
        prescription: prescription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Novo exercício')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Nome do exercício',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _muscleGroup,
              decoration: const InputDecoration(labelText: 'Grupo muscular'),
              items: _muscleGroups
                  .map(
                    (group) =>
                        DropdownMenuItem(value: group, child: Text(group)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _muscleGroup = value),
            ),
            const SizedBox(height: 24),
            Text('Prescrição', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            AppTextField(
              controller: _setCountController,
              label: 'Quantidade de séries',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _repetitionsController,
              label: 'Repetições',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _weightController,
              label: 'Peso em kg (opcional)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _restController,
              label: 'Descanso em segundos',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: 'Observação (opcional)',
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Adicionar exercício',
              icon: Icons.add,
              onPressed: _saveExercise,
            ),
          ],
        ),
      ),
    ),
  );
}
