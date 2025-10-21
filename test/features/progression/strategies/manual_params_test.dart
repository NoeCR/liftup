import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('Manual Parameters Tests', () {
    late Exercise testExercise;
    late ProgressionConfig configWithManualParams;
    late ProgressionConfig configWithoutManualParams;
    late ProgressionState testState;

    setUp(() {
      testExercise = Exercise(
        id: 'test-exercise',
        name: 'Test Exercise',
        description: 'Test exercise for manual params',
        imageUrl: 'test-image.jpg',
        muscleGroups: [MuscleGroup.pectoralMajor],
        tips: ['Test tip'],
        commonMistakes: ['Test mistake'],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

      testState = ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 3,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );

      // Configuración CON parámetros manuales
      configWithManualParams = ProgressionConfig(
        id: 'manual-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 5.0, // Valor manual
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        customParameters: {'use_manual_params': true},
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        minReps: 6, // Valor manual
        maxReps: 12, // Valor manual
        baseSets: 4, // Valor manual
      );

      // Configuración SIN parámetros manuales (usa objetivo)
      configWithoutManualParams = ProgressionConfig(
        id: 'objective-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5, // Valor base
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        customParameters: {'use_manual_params': false},
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        minReps: 8, // Valor base
        maxReps: 15, // Valor base
        baseSets: 3, // Valor base
      );
    });

    group('Linear Progression Strategy - Manual Parameters', () {
      late LinearProgressionStrategy strategy;

      setUp(() {
        strategy = LinearProgressionStrategy();
      });

      test(
        'should use manual increment value when use_manual_params is true',
        () {
          final result = strategy.getIncrementValueSync(
            configWithManualParams,
            testExercise,
            testState,
          );

          expect(result, equals(5.0)); // Valor manual del config
        },
      );

      test('should use adaptive increment when use_manual_params is false', () {
        final result = strategy.getIncrementValueSync(
          configWithoutManualParams,
          testExercise,
          testState,
        );

        // Debería usar el valor adaptativo, no el manual
        expect(result, isNot(equals(2.5))); // No debería usar el valor base
        expect(result, greaterThan(0)); // Debería ser un valor adaptativo
      });

      test('should use manual min reps when use_manual_params is true', () {
        final result = strategy.getMinRepsSync(
          configWithManualParams,
          testExercise,
        );

        expect(result, equals(6)); // Valor manual del config
      });

      test('should use manual max reps when use_manual_params is true', () {
        final result = strategy.getMaxRepsSync(
          configWithManualParams,
          testExercise,
        );

        expect(result, equals(12)); // Valor manual del config
      });

      test('should use manual base sets when use_manual_params is true', () {
        final result = strategy.getBaseSetsSync(
          configWithManualParams,
          testExercise,
        );

        expect(result, equals(4)); // Valor manual del config
      });

      test('should use adaptive values when use_manual_params is false', () {
        final minReps = strategy.getMinRepsSync(
          configWithoutManualParams,
          testExercise,
        );
        final maxReps = strategy.getMaxRepsSync(
          configWithoutManualParams,
          testExercise,
        );
        final baseSets = strategy.getBaseSetsSync(
          configWithoutManualParams,
          testExercise,
        );

        // Deberían usar valores adaptativos, no los valores base del config
        expect(minReps, isNot(equals(8)));
        expect(maxReps, isNot(equals(15)));
        expect(baseSets, isNot(equals(3)));

        // Pero deberían ser valores válidos
        expect(minReps, greaterThan(0));
        expect(maxReps, greaterThan(minReps));
        expect(baseSets, greaterThan(0));
      });
    });

    group('Double Factor Progression - Manual Parameters', () {
      late DoubleFactorProgressionStrategy strategy;

      setUp(() {
        strategy = DoubleFactorProgressionStrategy();
      });

      test('should use manual parameters in double factor progression', () {
        // Verificar que se usan los valores manuales
        final minReps = strategy.getMinRepsSync(
          configWithManualParams,
          testExercise,
        );
        final maxReps = strategy.getMaxRepsSync(
          configWithManualParams,
          testExercise,
        );
        final baseSets = strategy.getBaseSetsSync(
          configWithManualParams,
          testExercise,
        );

        expect(minReps, equals(6));
        expect(maxReps, equals(12));
        expect(baseSets, equals(4));
      });

      test(
        'should respect manual parameters in double factor mode selection',
        () {
          final configWithMode = configWithManualParams.copyWith(
            customParameters: {
              ...configWithManualParams.customParameters,
              'double_factor_mode': 'both',
            },
          );

          // Verificar que los valores manuales se mantienen
          final minReps = strategy.getMinRepsSync(configWithMode, testExercise);
          final maxReps = strategy.getMaxRepsSync(configWithMode, testExercise);
          final baseSets = strategy.getBaseSetsSync(
            configWithMode,
            testExercise,
          );

          expect(minReps, equals(6));
          expect(maxReps, equals(12));
          expect(baseSets, equals(4));
        },
      );
    });

    group('Edge Cases - Manual Parameters', () {
      late LinearProgressionStrategy strategy;

      setUp(() {
        strategy = LinearProgressionStrategy();
      });

      test('should handle null use_manual_params as false', () {
        final configWithNull = configWithManualParams.copyWith(
          customParameters: {
            ...configWithManualParams.customParameters,
            'use_manual_params': null,
          },
        );

        final result = strategy.getIncrementValueSync(
          configWithNull,
          testExercise,
          testState,
        );

        // Debería usar valores adaptativos, no manuales
        expect(result, isNot(equals(5.0)));
        expect(result, greaterThan(0));
      });

      test('should handle false use_manual_params explicitly', () {
        final configWithFalse = configWithManualParams.copyWith(
          customParameters: {
            ...configWithManualParams.customParameters,
            'use_manual_params': false,
          },
        );

        final result = strategy.getIncrementValueSync(
          configWithFalse,
          testExercise,
          testState,
        );

        // Debería usar valores adaptativos, no manuales
        expect(result, isNot(equals(5.0)));
        expect(result, greaterThan(0));
      });

      test('should handle missing use_manual_params key', () {
        final configWithoutKey = configWithManualParams.copyWith(
          customParameters: {},
        );

        final result = strategy.getIncrementValueSync(
          configWithoutKey,
          testExercise,
          testState,
        );

        // Debería usar valores adaptativos por defecto
        expect(result, isNot(equals(5.0)));
        expect(result, greaterThan(0));
      });
    });

    group('Integration - Manual Parameters with Different Strategies', () {
      test('Linear Progression with manual parameters', () {
        final strategy = LinearProgressionStrategy();

        // Verificar que los valores manuales se usan correctamente
        final increment = strategy.getIncrementValueSync(
          configWithManualParams,
          testExercise,
          testState,
        );
        final minReps = strategy.getMinRepsSync(
          configWithManualParams,
          testExercise,
        );
        final maxReps = strategy.getMaxRepsSync(
          configWithManualParams,
          testExercise,
        );
        final baseSets = strategy.getBaseSetsSync(
          configWithManualParams,
          testExercise,
        );

        expect(increment, equals(5.0));
        expect(minReps, equals(6));
        expect(maxReps, equals(12));
        expect(baseSets, equals(4));
      });

      test('Double Factor Progression with manual parameters', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Verificar que los valores manuales se usan correctamente
        final minReps = strategy.getMinRepsSync(
          configWithManualParams,
          testExercise,
        );
        final maxReps = strategy.getMaxRepsSync(
          configWithManualParams,
          testExercise,
        );
        final baseSets = strategy.getBaseSetsSync(
          configWithManualParams,
          testExercise,
        );

        expect(minReps, equals(6));
        expect(maxReps, equals(12));
        expect(baseSets, equals(4));
      });
    });
  });
}
