import 'package:flutter/material.dart';

import '../../shared/models/workout.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

class NewWorkoutPage extends StatefulWidget {
  final Workout? workout;
  const NewWorkoutPage({super.key, this.workout});
  @override
  State<NewWorkoutPage> createState() => _NewWorkoutPageState();
}

class _NewWorkoutPageState extends State<NewWorkoutPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool get _isEditing => widget.workout != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.workout?.name ?? '';
    _descriptionController.text = widget.workout?.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveWorkout() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do treino.')),
      );
      return;
    }
    final description = _descriptionController.text.trim();
    Navigator.pop(
      context,
      widget.workout?.copyWith(name: name, description: description) ??
          Workout.create(name: name, description: description),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEditing ? 'Editar treino' : 'Novo treino')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppTextField(controller: _nameController, label: 'Nome do treino'),
          const SizedBox(height: 20),
          AppTextField(
            controller: _descriptionController,
            label: 'Descrição (opcional)',
          ),
          const Spacer(),
          AppButton(
            text: _isEditing ? 'Salvar alterações' : 'Salvar',
            icon: Icons.save,
            onPressed: _saveWorkout,
          ),
        ],
      ),
    ),
  );
}
