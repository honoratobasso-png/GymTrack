import 'package:flutter_test/flutter_test.dart';
import 'package:gymtrack/shared/services/id_generator.dart';

void main() {
  test('gerador produz UUID v4 no formato esperado', () {
    final id = IdGenerator.generate();
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(id),
      isTrue,
    );
  });
}
