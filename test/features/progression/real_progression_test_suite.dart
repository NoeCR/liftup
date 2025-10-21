import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

/// Suite de pruebas real para la funcionalidad de progresión
///
/// Este archivo ejecuta tests funcionales que validan el comportamiento
/// real de las estrategias de progresión.
void main() {
  group('Real Progression Test Suite', () {
    late Exercise testExercise;
    late ProgressionConfig testConfig;
    late ProgressionState testState;

    setUp(() {
      // Configurar ejercicio de prueba
      testExercise = Exercise(
        id: 'test-exercise',
        name: 'Test Exercise',
        description: 'Test exercise for progression',
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

      // Configurar estado de progresión
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

      // Configurar configuración de progresión
      testConfig = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        customParameters: {},
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        minReps: 6,
        maxReps: 12,
        baseSets: 3,
      );
    });

    group('Linear Progression Strategy Tests', () {
      late LinearProgressionStrategy strategy;

      setUp(() {
        strategy = LinearProgressionStrategy();
      });

      test('should calculate increment value correctly', () {
        final increment = strategy.getIncrementValueSync(testConfig, testExercise, testState);

        expect(increment, greaterThan(0));
        expect(increment, isA<double>());
      });

      test('should get min reps correctly', () {
        final minReps = strategy.getMinRepsSync(testConfig, testExercise);

        expect(minReps, greaterThan(0));
        expect(minReps, isA<int>());
      });

      test('should get max reps correctly', () {
        final maxReps = strategy.getMaxRepsSync(testConfig, testExercise);

        expect(maxReps, greaterThan(0));
        expect(maxReps, isA<int>());
      });

      test('should get base sets correctly', () {
        final baseSets = strategy.getBaseSetsSync(testConfig, testExercise);

        expect(baseSets, greaterThan(0));
        expect(baseSets, isA<int>());
      });

      test('should validate progression parameters', () {
        final isValid = strategy.validateProgressionParams(testConfig);

        expect(isValid, isTrue);
      });

      test('should validate progression state', () {
        final isValid = strategy.validateProgressionState(testState);

        expect(isValid, isTrue);
      });
    });

    group('Double Factor Progression Strategy Tests', () {
      late DoubleFactorProgressionStrategy strategy;

      setUp(() {
        strategy = DoubleFactorProgressionStrategy();
      });

      test('should calculate increment value correctly', () {
        final increment = strategy.getIncrementValueSync(testConfig, testExercise, testState);

        expect(increment, greaterThan(0));
        expect(increment, isA<double>());
      });

      test('should get min reps correctly', () {
        final minReps = strategy.getMinRepsSync(testConfig, testExercise);

        expect(minReps, greaterThan(0));
        expect(minReps, isA<int>());
      });

      test('should get max reps correctly', () {
        final maxReps = strategy.getMaxRepsSync(testConfig, testExercise);

        expect(maxReps, greaterThan(0));
        expect(maxReps, isA<int>());
      });

      test('should get base sets correctly', () {
        final baseSets = strategy.getBaseSetsSync(testConfig, testExercise);

        expect(baseSets, greaterThan(0));
        expect(baseSets, isA<int>());
      });

      test('should validate progression parameters', () {
        final isValid = strategy.validateProgressionParams(testConfig);

        expect(isValid, isTrue);
      });

      test('should validate progression state', () {
        final isValid = strategy.validateProgressionState(testState);

        expect(isValid, isTrue);
      });
    });

    group('Manual Parameters Tests', () {
      late LinearProgressionStrategy strategy;
      late ProgressionConfig manualConfig;

      setUp(() {
        strategy = LinearProgressionStrategy();

        manualConfig = testConfig.copyWith(
          customParameters: {'use_manual_params': true},
          incrementValue: 5.0,
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );
      });

      test('should use manual increment value when use_manual_params is true', () {
        final increment = strategy.getIncrementValueSync(manualConfig, testExercise, testState);

        expect(increment, equals(5.0));
      });

      test('should use manual min reps when use_manual_params is true', () {
        final minReps = strategy.getMinRepsSync(manualConfig, testExercise);

        expect(minReps, equals(6));
      });

      test('should use manual max reps when use_manual_params is true', () {
        final maxReps = strategy.getMaxRepsSync(manualConfig, testExercise);

        expect(maxReps, equals(12));
      });

      test('should use manual base sets when use_manual_params is true', () {
        final baseSets = strategy.getBaseSetsSync(manualConfig, testExercise);

        expect(baseSets, equals(4));
      });
    });

    group('Configuration Validation Tests', () {
      test('should validate valid progression config', () {
        final isValid =
            testConfig.minReps > 0 &&
            testConfig.maxReps > 0 &&
            testConfig.minReps <= testConfig.maxReps &&
            testConfig.baseSets > 0 &&
            testConfig.cycleLength > 0 &&
            testConfig.deloadPercentage > 0 &&
            testConfig.deloadPercentage <= 1.0;

        expect(isValid, isTrue);
      });

      test('should validate valid progression state', () {
        final isValid =
            testState.currentWeight >= 0 &&
            testState.currentReps > 0 &&
            testState.currentSets > 0 &&
            testState.currentSession > 0;

        expect(isValid, isTrue);
      });

      test('should handle invalid config parameters', () {
        final invalidConfig = testConfig.copyWith(
          minReps: 0, // Invalid
          maxReps: -1, // Invalid
          baseSets: 0, // Invalid
        );

        final isValid =
            invalidConfig.minReps > 0 &&
            invalidConfig.maxReps > 0 &&
            invalidConfig.minReps <= invalidConfig.maxReps &&
            invalidConfig.baseSets > 0;

        expect(isValid, isFalse);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle null use_manual_params', () {
        final configWithNull = testConfig.copyWith(customParameters: {'use_manual_params': null});

        final strategy = LinearProgressionStrategy();
        final increment = strategy.getIncrementValueSync(configWithNull, testExercise, testState);

        // Debería usar valores adaptativos, no manuales
        expect(increment, isNot(equals(2.5)));
        expect(increment, greaterThan(0));
      });

      test('should handle missing use_manual_params key', () {
        final configWithoutKey = testConfig.copyWith(customParameters: {});

        final strategy = LinearProgressionStrategy();
        final increment = strategy.getIncrementValueSync(configWithoutKey, testExercise, testState);

        // Debería usar valores adaptativos por defecto
        expect(increment, isNot(equals(2.5)));
        expect(increment, greaterThan(0));
      });

      test('should handle false use_manual_params explicitly', () {
        final configWithFalse = testConfig.copyWith(customParameters: {'use_manual_params': false});

        final strategy = LinearProgressionStrategy();
        final increment = strategy.getIncrementValueSync(configWithFalse, testExercise, testState);

        // Debería usar valores adaptativos, no manuales
        expect(increment, isNot(equals(2.5)));
        expect(increment, greaterThan(0));
      });
    });

    group('Integration Tests', () {
      test('should work with different exercise types', () {
        final isolationExercise = testExercise.copyWith(exerciseType: ExerciseType.isolation);

        final strategy = LinearProgressionStrategy();
        final increment = strategy.getIncrementValueSync(testConfig, isolationExercise, testState);

        expect(increment, greaterThan(0));
      });

      test('should work with different load types', () {
        final dumbbellExercise = testExercise.copyWith(loadType: LoadType.dumbbell);

        final strategy = LinearProgressionStrategy();
        final increment = strategy.getIncrementValueSync(testConfig, dumbbellExercise, testState);

        expect(increment, greaterThan(0));
      });

      test('should work with different difficulty levels', () {
        final beginnerExercise = testExercise.copyWith(difficulty: ExerciseDifficulty.beginner);

        final strategy = LinearProgressionStrategy();
        final increment = strategy.getIncrementValueSync(testConfig, beginnerExercise, testState);

        expect(increment, greaterThan(0));
      });
    });
  });
}
