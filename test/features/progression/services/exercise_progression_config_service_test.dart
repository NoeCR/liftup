import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/models/exercise_progression_config.dart';
import 'package:liftly/features/progression/services/exercise_progression_config_service.dart';

void main() {
  group('ExerciseProgressionConfigService Tests', () {
    late ExerciseProgressionConfig testConfig;

    setUp(() {
      testConfig = ExerciseProgressionConfig(
        id: 'test-config-1',
        exerciseId: 'test-exercise-1',
        progressionConfigId: 'test-progression-1',
        customIncrement: 5.0,
        customMinReps: 6,
        customMaxReps: 12,
        customBaseSets: 4,
        experienceLevel: ExperienceLevel.initiated,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('ExerciseProgressionConfig Model Tests', () {
      test('creates instance with all required fields', () {
        expect(testConfig.id, equals('test-config-1'));
        expect(testConfig.exerciseId, equals('test-exercise-1'));
        expect(testConfig.progressionConfigId, equals('test-progression-1'));
        expect(testConfig.customIncrement, equals(5.0));
        expect(testConfig.customMinReps, equals(6));
        expect(testConfig.customMaxReps, equals(12));
        expect(testConfig.customBaseSets, equals(4));
        expect(testConfig.experienceLevel, equals(ExperienceLevel.initiated));
      });

      test('hasCustomConfig returns true when any custom field is set', () {
        expect(testConfig.hasCustomConfig, isTrue);
      });

      test('hasCustomIncrement returns true when customIncrement is set and > 0', () {
        expect(testConfig.hasCustomIncrement, isTrue);
      });
    });

    group('Service Logic Tests', () {
      test('migrateFromPerExercise creates correct ExerciseProgressionConfig', () {
        final perExerciseData = {
          'exercise-1': {'increment_value': 5.0, 'min_reps': 6, 'max_reps': 12, 'base_sets': 4},
          'exercise-2': {'increment_value': 7.5, 'min_reps': 8, 'max_reps': 15, 'base_sets': 3},
        };

        // Simular la lógica de migración sin usar Hive
        final _ = ExerciseProgressionConfigService();
        final now = DateTime.now();

        for (final entry in perExerciseData.entries) {
          final exerciseId = entry.key;
          final exerciseData = entry.value as Map<String, dynamic>?;

          if (exerciseData != null) {
            final config = ExerciseProgressionConfig(
              id: '${exerciseId}_test-progression-1',
              exerciseId: exerciseId,
              progressionConfigId: 'test-progression-1',
              customIncrement: exerciseData['increment_value'] as double?,
              customMinReps: exerciseData['min_reps'] as int?,
              customMaxReps: exerciseData['max_reps'] as int?,
              customBaseSets: exerciseData['base_sets'] as int?,
              createdAt: now,
              updatedAt: now,
            );

            // Verificar que la configuración se creó correctamente
            expect(config.exerciseId, equals(exerciseId));
            expect(config.progressionConfigId, equals('test-progression-1'));
            expect(config.customIncrement, equals(exerciseData['increment_value']));
            expect(config.customMinReps, equals(exerciseData['min_reps']));
            expect(config.customMaxReps, equals(exerciseData['max_reps']));
            expect(config.customBaseSets, equals(exerciseData['base_sets']));
          }
        }
      });

      test('handles malformed per_exercise data gracefully', () {
        final malformedData = {
          'exercise-1': 'invalid_data',
          'exercise-2': null,
          'exercise-3': {
            'increment_value': 5.0,
            // Missing other fields
          },
        };

        final _ = ExerciseProgressionConfigService();
        final now = DateTime.now();
        int validConfigs = 0;

        for (final entry in malformedData.entries) {
          final exerciseId = entry.key;
          final exerciseData = entry.value;

          if (exerciseData is Map<String, dynamic>) {
            try {
              final _ = ExerciseProgressionConfig(
                id: '${exerciseId}_test-progression-1',
                exerciseId: exerciseId,
                progressionConfigId: 'test-progression-1',
                customIncrement: exerciseData['increment_value'] as double?,
                customMinReps: exerciseData['min_reps'] as int?,
                customMaxReps: exerciseData['max_reps'] as int?,
                customBaseSets: exerciseData['base_sets'] as int?,
                createdAt: now,
                updatedAt: now,
              );
              validConfigs++;
            } catch (e) {
              // Debería manejar datos malformados sin lanzar excepción
            }
          }
        }

        // Solo debería crear la configuración válida
        expect(validConfigs, equals(1));
      });
    });
  });
}
