import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/pages/exercise_form_page.dart';

void main() {
  test('buildPerExerciseOverrideMap construye overrides específicos del ejercicio', () {
    final map = buildPerExerciseOverrideMap(
      setsMin: 3,
      setsMax: 5,
      targetRpe: 8,
      incrementFrequency: 2,
      unit: ProgressionUnit.week,
    );

    // Los incrementos de peso y rangos de reps se manejan automáticamente
    // por AdaptiveIncrementConfig y ProgressionConfig
    expect(map['sets_min'], 3);
    expect(map['sets_max'], 5);
    expect(map['target_rpe'], 8);
    expect(map['increment_frequency'], 2);
    expect(map['unit'], 'week');
  });

  test('buildPerExerciseOverrideMap omite claves nulas', () {
    final map = buildPerExerciseOverrideMap(
      setsMin: null,
      setsMax: null,
      targetRpe: null,
      incrementFrequency: 1,
      unit: null,
    );

    expect(map.containsKey('sets_min'), false);
    expect(map.containsKey('sets_max'), false);
    expect(map.containsKey('target_rpe'), false);
    expect(map['increment_frequency'], 1);
    expect(map.containsKey('unit'), false);
  });
}
