import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/shared/models/exercise.dart';
import 'package:gymtrack/shared/models/exercise_prescription.dart';

void main() {
  test(
    'prescrição gera séries independentes com a configuração solicitada',
    () {
      const prescription = ExercisePrescription(
        setCount: 4,
        repetitions: 12,
        weight: 20,
        restSeconds: 60,
      );
      final exercise = Exercise.create(
        name: 'Supino',
        muscleGroup: 'Peito',
        order: 1,
        prescription: prescription,
      );

      expect(exercise.sets, hasLength(4));
      expect(exercise.sets.map((set) => set.order), [1, 2, 3, 4]);
      expect(
        exercise.sets.every(
          (set) =>
              set.repetitions == 12 &&
              set.weight == 20 &&
              set.restSeconds == 60,
        ),
        isTrue,
      );
      expect(exercise.sets.map((set) => set.id).toSet(), hasLength(4));
    },
  );
}
