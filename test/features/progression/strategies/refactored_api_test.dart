import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

/// Tests para validar la nueva API simplificada y robusta
void main() {
  group('Refactored API Tests', () {
    late LinearProgressionStrategy strategy;
    late ProgressionConfig preset;
    late Exercise testExercise;
    late ProgressionState testState;

    setUpAll(() {
      strategy = LinearProgressionStrategy();
      preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

      testExercise = Exercise(
        id: 'test-exercise',
        name: 'Test Exercise',
        description: 'Test exercise for API validation',
        imageUrl: '',
        muscleGroups: [MuscleGroup.pectoralMajor],
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

      testState = ProgressionState(
        id: 'test',
        progressionConfigId: 'test-config',
        exerciseId: testExercise.id,
        routineId: 'test',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: preset.minReps,
        currentSets: preset.baseSets,
        baseWeight: 100.0,
        baseReps: preset.minReps,
        baseSets: preset.baseSets,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );
    });

    group('New API Requirements', () {
      test('should require Exercise object for progression', () {
        final result = strategy.calculate(
          config: preset,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: null, // Sin ejercicio
        );

        expect(result.incrementApplied, isFalse);
        expect(result.reason, contains('exercise required'));
      });

      test('should work correctly with Exercise object', () {
        final result = strategy.calculate(
          config: preset,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: testExercise,
        );

        expect(result.incrementApplied, isTrue);
        expect(result.newWeight, equals(106.0)); // 100 + 6.0 (AdaptiveIncrementConfig)
        expect(result.reason, contains('+6.0kg'));
      });
    });

    group('Per-Exercise Configuration', () {
      test('should use per_exercise configuration when available', () {
        final configWithPerExercise = preset.copyWith(
          customParameters: {
            ...preset.customParameters,
            'per_exercise': {
              'test-exercise': {'increment_value': 5.0, 'max_reps': 15, 'min_reps': 6, 'base_sets': 4},
            },
          },
        );

        final result = strategy.calculate(
          config: configWithPerExercise,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: testExercise,
        );

        expect(result.incrementApplied, isTrue);
        expect(result.newWeight, equals(105.0)); // 100 + 5.0 (per_exercise)
        expect(result.newSets, equals(4)); // per_exercise base_sets
        expect(result.reason, contains('+5.0kg'));
      });

      test('should fallback to AdaptiveIncrementConfig when per_exercise not found', () {
        // Crear un preset limpio sin per_exercise para evitar conflictos
        final cleanPreset = PresetProgressionConfigs.createLinearHypertrophyPreset().copyWith(
          customParameters: {
            'per_exercise': {
              'other-exercise': {
                // Diferente ID
                'increment_value': 5.0,
              },
            },
          },
        );

        final result = strategy.calculate(
          config: cleanPreset,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: testExercise,
        );

        expect(result.incrementApplied, isTrue);
        expect(result.newWeight, equals(105.0)); // 100 + 5.0 (AdaptiveIncrementConfig fallback)
        expect(result.reason, contains('+5.0kg'));
      });

      test('should handle malformed per_exercise gracefully', () {
        final configWithMalformedPerExercise = preset.copyWith(
          customParameters: {
            ...preset.customParameters,
            'per_exercise': {
              'test-exercise': 'invalid_data', // Datos malformados
            },
          },
        );

        final result = strategy.calculate(
          config: configWithMalformedPerExercise,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: testExercise,
        );

        expect(result.incrementApplied, isTrue);
        expect(result.newWeight, equals(106.0)); // 100 + 6.0 (AdaptiveIncrementConfig fallback)
        expect(result.reason, contains('+6.0kg'));
      });
    });

    group('API Simplification Benefits', () {
      test('should have consistent behavior across all methods', () {
        // Test que todos los métodos helper requieren Exercise
        expect(() => strategy.getIncrementValueSync(preset, testExercise), returnsNormally);
        expect(() => strategy.getMaxRepsSync(preset, testExercise), returnsNormally);
        expect(() => strategy.getMinRepsSync(preset, testExercise), returnsNormally);
        expect(() => strategy.getBaseSetsSync(preset, testExercise), returnsNormally);
      });

      test('should provide clear error messages when exercise is missing', () {
        final result = strategy.calculate(
          config: preset,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: null,
        );

        expect(result.reason, contains('exercise required'));
        expect(result.incrementApplied, isFalse);
      });
    });

    group('Backward Compatibility', () {
      test('should maintain same results as original implementation for valid cases', () {
        // Test que los resultados son consistentes con la implementación original
        // cuando se proporciona un Exercise válido
        final result = strategy.calculate(
          config: preset,
          state: testState,
          routineId: 'test',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 3,
          exercise: testExercise,
        );

        // Debería usar AdaptiveIncrementConfig (6.0 para barbell multi-joint)
        expect(result.newWeight, equals(106.0));
        expect(result.incrementApplied, isTrue);
        expect(result.reason, contains('Linear progression'));
      });
    });
  });
}
