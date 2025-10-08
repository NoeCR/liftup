import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/pages/exercise_form_page.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  test(
    'buildPerExerciseOverrideMap construye overrides multi_/iso_ y unit',
    () {
      final map = buildPerExerciseOverrideMap(
        incrementMin: 2.0,
        incrementMax: 5.0,
        repsMin: 8,
        repsMax: 12,
        setsMin: 3,
        setsMax: 5,
        targetRpe: 8,
        incrementFrequency: 2,
        unit: ProgressionUnit.week,
      );

      expect(map['multi_increment_min'], 2.0);
      expect(map['multi_increment_max'], 5.0);
      expect(map['multi_reps_min'], 8);
      expect(map['multi_reps_max'], 12);
      expect(map['iso_increment_min'], 2.0);
      expect(map['iso_increment_max'], 5.0);
      expect(map['iso_reps_min'], 8);
      expect(map['iso_reps_max'], 12);
      expect(map['sets_min'], 3);
      expect(map['sets_max'], 5);
      expect(map['target_rpe'], 8);
      expect(map['increment_frequency'], 2);
      expect(map['unit'], 'week');
    },
  );

  test('buildPerExerciseOverrideMap omite claves nulas', () {
    final map = buildPerExerciseOverrideMap(
      incrementMin: null,
      incrementMax: 2.5,
      repsMin: null,
      repsMax: 10,
      setsMin: null,
      setsMax: null,
      targetRpe: null,
      incrementFrequency: 1,
      unit: null,
    );

    expect(map.containsKey('multi_increment_min'), false);
    expect(map['multi_increment_max'], 2.5);
    expect(map.containsKey('multi_reps_min'), false);
    expect(map['multi_reps_max'], 10);
    expect(map['iso_increment_max'], 2.5);
    expect(map['iso_reps_max'], 10);
    expect(map['increment_frequency'], 1);
    expect(map.containsKey('unit'), false);
  });
}
