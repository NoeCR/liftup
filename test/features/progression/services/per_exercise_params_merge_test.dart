import 'package:flutter_test/flutter_test.dart';

import 'package:liftly/features/progression/services/session_progression_service.dart';
import 'package:liftly/features/exercise/models/exercise.dart';

void main() {
  group('buildMergedCustomForExercise', () {
    test('aplica overrides por ejercicio sobre los globales', () {
      const exerciseId = 'ex-1';
      final global = <String, dynamic>{
        'multi_increment_min': 2.5,
        'multi_increment_max': 5.0,
        'multi_reps_min': 15,
        'multi_reps_max': 20,
        'per_exercise': {
          exerciseId: {'multi_increment_min': 3.0, 'multi_reps_max': 18},
        },
      };

      final merged = buildMergedCustomForExercise(
        globalCustom: global,
        exerciseId: exerciseId,
      );

      expect(merged['multi_increment_min'], 3.0); // override
      expect(merged['multi_increment_max'], 5.0); // global
      expect(merged['multi_reps_min'], 15); // global
      expect(merged['multi_reps_max'], 18); // override
    });

    test('ignora claves ajenas como unit sin afectar ajustes', () {
      const exerciseId = 'ex-unit';
      final global = <String, dynamic>{
        'multi_increment_min': 2.5,
        'multi_increment_max': 5.0,
        'multi_reps_min': 12,
        'multi_reps_max': 16,
        'per_exercise': {
          exerciseId: {'multi_increment_min': 3.0, 'unit': 'week'},
        },
      };

      final merged = buildMergedCustomForExercise(
        globalCustom: global,
        exerciseId: exerciseId,
      );

      expect(merged['multi_increment_min'], 3.0);
      expect(merged['multi_increment_max'], 5.0);
      // La clave unit puede estar en custom, pero _adjustByExerciseType no la usa
      final result = debugAdjustByExerciseType(
        exerciseType: ExerciseType.multiJoint,
        currentWeight: 100,
        proposedWeight: 103,
        proposedReps: 20,
        custom: merged,
        incrementApplied: true,
      );
      expect(result['weight'], 103.0);
      expect(result['reps'], 16); // clamp por multi_reps_max global
    });
    test('si no hay per_exercise usa solo globales (fallback)', () {
      const exerciseId = 'ex-2';
      final global = <String, dynamic>{
        'iso_increment_min': 1.25,
        'iso_increment_max': 2.5,
        'iso_reps_min': 8,
        'iso_reps_max': 12,
      };

      final merged = buildMergedCustomForExercise(
        globalCustom: global,
        exerciseId: exerciseId,
      );

      expect(merged['iso_increment_min'], 1.25);
      expect(merged['iso_increment_max'], 2.5);
      expect(merged['iso_reps_min'], 8);
      expect(merged['iso_reps_max'], 12);
    });

    test(
      'si per_exercise no tiene entrada para el ejercicio, usa globales',
      () {
        const exerciseId = 'ex-3';
        final global = <String, dynamic>{
          'multi_increment_min': 2.5,
          'per_exercise': {
            'otro': {'multi_increment_min': 4.0},
          },
        };

        final merged = buildMergedCustomForExercise(
          globalCustom: global,
          exerciseId: exerciseId,
        );

        expect(merged['multi_increment_min'], 2.5);
      },
    );
  });

  group('debugAdjustByExerciseType con merged params', () {
    test('usa overrides para clamp de reps y escalón de peso (multiJoint)', () {
      final overrides = {
        'multi_increment_min': 3.0,
        'multi_increment_max': 6.0,
        'multi_reps_min': 12,
        'multi_reps_max': 14,
      };
      final result = debugAdjustByExerciseType(
        exerciseType: ExerciseType.multiJoint,
        currentWeight: 100,
        proposedWeight: 103.7, // delta 3.7 => se ajusta a min 3.0
        proposedReps: 30, // clamp a 14
        custom: overrides,
        incrementApplied: true,
      );
      expect(result['weight'], 103.0);
      expect(result['reps'], 14);
    });

    test('fallback a global si no hay overrides (isolation)', () {
      final global = {
        'iso_increment_min': 1.25,
        'iso_increment_max': 2.5,
        'iso_reps_min': 8,
        'iso_reps_max': 12,
      };
      final result = debugAdjustByExerciseType(
        exerciseType: ExerciseType.isolation,
        currentWeight: 20,
        proposedWeight: 21.1, // delta 1.1 => fuerza min 1.25
        proposedReps: 6, // clamp a 8
        custom: global,
        incrementApplied: true,
      );
      expect(result['weight'], 21.25);
      expect(result['reps'], 8);
    });
  });
}
