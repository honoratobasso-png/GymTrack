import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/shared/models/workout.dart';

void main() {
  test(
    'arquivamento preserva a identidade e restauração remove o estado de arquivo',
    () {
      final workout = Workout.create(name: 'A');
      final archived = workout.archive();
      final restored = archived.restore();

      expect(archived.id, workout.id);
      expect(archived.isArchived, isTrue);
      expect(archived.archivedAt, isNotNull);
      expect(restored.id, workout.id);
      expect(restored.isArchived, isFalse);
      expect(restored.archivedAt, isNull);
    },
  );
}
