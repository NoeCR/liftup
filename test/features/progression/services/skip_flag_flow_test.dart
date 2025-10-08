import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/services/session_progression_service.dart';

void main() {
  test('evaluateAndConsumeSkipForRoutine returns skip and removes flag', () {
    final initial = {
      'skip_next_by_routine': {'r1': true, 'r2': true},
    };
    final res = evaluateAndConsumeSkipForRoutine(
      customData: initial,
      routineId: 'r1',
    );
    expect(res['skip'], true);
    final cleaned = res['custom'] as Map<String, dynamic>;
    final map = cleaned['skip_next_by_routine'] as Map;
    expect(map.containsKey('r1'), false);
    expect(map['r2'], true);
  });

  test('evaluateAndConsumeSkipForRoutine returns no-skip and keeps others', () {
    final initial = {
      'skip_next_by_routine': {'r2': true},
    };
    final res = evaluateAndConsumeSkipForRoutine(
      customData: initial,
      routineId: 'r1',
    );
    expect(res['skip'], false);
    final cleaned = res['custom'] as Map<String, dynamic>;
    final map = cleaned['skip_next_by_routine'] as Map;
    expect(map['r2'], true);
  });
}
