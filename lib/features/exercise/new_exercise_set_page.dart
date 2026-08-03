import 'package:flutter/material.dart';

import '../../shared/models/exercise_set.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

class NewExerciseSetPage extends StatefulWidget {
  final int initialOrder;
  const NewExerciseSetPage({super.key, required this.initialOrder});
  @override
  State<NewExerciseSetPage> createState() => _NewExerciseSetPageState();
}

class _NewExerciseSetPageState extends State<NewExerciseSetPage> {
  final _repetitionsController = TextEditingController();
  final _weightController = TextEditingController();
  final _restController = TextEditingController(text: '60');
  final _durationController = TextEditingController();
  @override
  void dispose() {
    _repetitionsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveSet() {
    final repetitions = int.tryParse(_repetitionsController.text.trim());
    final restSeconds = int.tryParse(_restController.text.trim());
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final durationText = _durationController.text.trim();
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    final duration = durationText.isEmpty ? null : int.tryParse(durationText);
    if (repetitions == null ||
        repetitions < 1 ||
        restSeconds == null ||
        restSeconds < 0 ||
        (weightText.isNotEmpty && (weight == null || weight < 0)) ||
        (durationText.isNotEmpty && (duration == null || duration < 1))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha as repetições e valores válidos.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      ExerciseSet.create(
        order: widget.initialOrder,
        repetitions: repetitions,
        weight: weight,
        restSeconds: restSeconds,
        durationSeconds: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nova série')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppTextField(
            controller: _repetitionsController,
            label: 'Repetições',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _weightController,
            label: 'Peso em kg (opcional)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _restController,
            label: 'Descanso em segundos',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _durationController,
            label: 'Tempo do exercício (opcional)',
            keyboardType: TextInputType.number,
          ),
          const Spacer(),
          AppButton(
            text: 'Adicionar série',
            icon: Icons.add,
            onPressed: _saveSet,
          ),
        ],
      ),
    ),
  );
}
