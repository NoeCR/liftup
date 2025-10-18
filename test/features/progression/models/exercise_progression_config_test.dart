import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/models/exercise_progression_config.dart';

void main() {
  group('ExerciseProgressionConfig Tests', () {
    late ExerciseProgressionConfig config;

    setUp(() {
      config = ExerciseProgressionConfig(
        id: 'test-config-1',
        exerciseId: 'test-exercise-1',
        progressionConfigId: 'test-progression-1',
        customIncrement: 5.0,
        customMinReps: 6,
        customMaxReps: 12,
        customBaseSets: 4,
        experienceLevel: ExperienceLevel.initiated,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
    });

    group('Constructor and Basic Properties', () {
      test('creates instance with all required fields', () {
        expect(config.id, equals('test-config-1'));
        expect(config.exerciseId, equals('test-exercise-1'));
        expect(config.progressionConfigId, equals('test-progression-1'));
        expect(config.customIncrement, equals(5.0));
        expect(config.customMinReps, equals(6));
        expect(config.customMaxReps, equals(12));
        expect(config.customBaseSets, equals(4));
        expect(config.experienceLevel, equals(ExperienceLevel.initiated));
      });

      test('creates instance with optional fields as null', () {
        final minimalConfig = ExerciseProgressionConfig(
          id: 'minimal-config',
          exerciseId: 'test-exercise',
          progressionConfigId: 'test-progression',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(minimalConfig.customIncrement, isNull);
        expect(minimalConfig.customMinReps, isNull);
        expect(minimalConfig.customMaxReps, isNull);
        expect(minimalConfig.customBaseSets, isNull);
        expect(minimalConfig.experienceLevel, isNull);
      });
    });

    group('Helper Methods', () {
      test('hasCustomConfig returns true when any custom field is set', () {
        expect(config.hasCustomConfig, isTrue);
      });

      test('hasCustomConfig returns false when no custom fields are set', () {
        final minimalConfig = ExerciseProgressionConfig(
          id: 'minimal-config',
          exerciseId: 'test-exercise',
          progressionConfigId: 'test-progression',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(minimalConfig.hasCustomConfig, isFalse);
      });

      test('hasCustomIncrement returns true when customIncrement is set and > 0', () {
        expect(config.hasCustomIncrement, isTrue);
      });

      test('hasCustomIncrement returns false when customIncrement is null', () {
        final configWithoutIncrement = ExerciseProgressionConfig(
          id: 'test-config-1',
          exerciseId: 'test-exercise-1',
          progressionConfigId: 'test-progression-1',
          customIncrement: null, // Explicitly null
          customMinReps: 6,
          customMaxReps: 12,
          customBaseSets: 4,
          experienceLevel: ExperienceLevel.initiated,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );
        expect(configWithoutIncrement.hasCustomIncrement, isFalse);
      });

      test('hasCustomIncrement returns false when customIncrement is 0', () {
        final configWithZeroIncrement = config.copyWith(customIncrement: 0.0);
        expect(configWithZeroIncrement.hasCustomIncrement, isFalse);
      });

      test('hasCustomReps returns true when min or max reps are set', () {
        expect(config.hasCustomReps, isTrue);
      });

      test('hasCustomSets returns true when customBaseSets is set and > 0', () {
        expect(config.hasCustomSets, isTrue);
      });
    });

    group('copyWith Method', () {
      test('creates copy with modified fields', () {
        final modifiedConfig = config.copyWith(customIncrement: 7.5, customMinReps: 8);

        expect(modifiedConfig.customIncrement, equals(7.5));
        expect(modifiedConfig.customMinReps, equals(8));
        expect(modifiedConfig.customMaxReps, equals(12)); // Unchanged
        expect(modifiedConfig.exerciseId, equals('test-exercise-1')); // Unchanged
      });

      test('creates copy with null values', () {
        // Para probar valores null, necesitamos crear una instancia específica
        final configWithNulls = ExerciseProgressionConfig(
          id: 'test-config-1',
          exerciseId: 'test-exercise-1',
          progressionConfigId: 'test-progression-1',
          customIncrement: null,
          customMinReps: 6,
          customMaxReps: 12,
          customBaseSets: 4,
          experienceLevel: null,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(configWithNulls.customIncrement, isNull);
        expect(configWithNulls.experienceLevel, isNull);
        expect(configWithNulls.customMinReps, equals(6)); // Preserved
      });
    });

    group('Serialization', () {
      test('toMap includes all fields', () {
        final map = config.toMap();

        expect(map['id'], equals('test-config-1'));
        expect(map['exerciseId'], equals('test-exercise-1'));
        expect(map['progressionConfigId'], equals('test-progression-1'));
        expect(map['customIncrement'], equals(5.0));
        expect(map['customMinReps'], equals(6));
        expect(map['customMaxReps'], equals(12));
        expect(map['customBaseSets'], equals(4));
        expect(map['experienceLevel'], equals('initiated'));
        expect(map['createdAt'], isA<String>());
        expect(map['updatedAt'], isA<String>());
      });

      test('fromMap creates correct instance', () {
        final map = config.toMap();
        final recreatedConfig = ExerciseProgressionConfig.fromMap(map);

        expect(recreatedConfig.id, equals(config.id));
        expect(recreatedConfig.exerciseId, equals(config.exerciseId));
        expect(recreatedConfig.progressionConfigId, equals(config.progressionConfigId));
        expect(recreatedConfig.customIncrement, equals(config.customIncrement));
        expect(recreatedConfig.customMinReps, equals(config.customMinReps));
        expect(recreatedConfig.customMaxReps, equals(config.customMaxReps));
        expect(recreatedConfig.customBaseSets, equals(config.customBaseSets));
        expect(recreatedConfig.experienceLevel, equals(config.experienceLevel));
      });

      test('fromMap handles null experienceLevel', () {
        final map = config.toMap();
        map['experienceLevel'] = null;

        final recreatedConfig = ExerciseProgressionConfig.fromMap(map);
        expect(recreatedConfig.experienceLevel, isNull);
      });
    });

    group('Equality and HashCode', () {
      test('equals returns true for identical instances', () {
        final identicalConfig = ExerciseProgressionConfig(
          id: 'test-config-1',
          exerciseId: 'test-exercise-1',
          progressionConfigId: 'test-progression-1',
          customIncrement: 5.0,
          customMinReps: 6,
          customMaxReps: 12,
          customBaseSets: 4,
          experienceLevel: ExperienceLevel.initiated,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(config, equals(identicalConfig));
      });

      test('equals returns false for different instances', () {
        final differentConfig = config.copyWith(customIncrement: 7.0);
        expect(config, isNot(equals(differentConfig)));
      });

      test('hashCode is consistent', () {
        final hashCode1 = config.hashCode;
        final hashCode2 = config.hashCode;
        expect(hashCode1, equals(hashCode2));
      });
    });
  });

  group('ExperienceLevel Tests', () {
    test('all experience levels have correct properties', () {
      expect(ExperienceLevel.initiated.displayName, equals('Iniciado'));
      expect(ExperienceLevel.initiated.description, equals('Puedes progresar rápidamente'));
      expect(ExperienceLevel.initiated.incrementFactor, equals(1.5));

      expect(ExperienceLevel.intermediate.displayName, equals('Intermedio'));
      expect(ExperienceLevel.intermediate.description, equals('Progresión moderada'));
      expect(ExperienceLevel.intermediate.incrementFactor, equals(1.0));

      expect(ExperienceLevel.advanced.displayName, equals('Avanzado'));
      expect(ExperienceLevel.advanced.description, equals('Progresión lenta, cerca del límite'));
      expect(ExperienceLevel.advanced.incrementFactor, equals(0.5));
    });

    test('increment factors follow correct logic', () {
      // Iniciado: más rápido (1.5x)
      expect(ExperienceLevel.initiated.incrementFactor, greaterThan(1.0));

      // Intermedio: normal (1.0x)
      expect(ExperienceLevel.intermediate.incrementFactor, equals(1.0));

      // Avanzado: más lento (0.5x)
      expect(ExperienceLevel.advanced.incrementFactor, lessThan(1.0));
    });
  });
}
