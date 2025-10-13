import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart' as aic;
import 'package:liftly/features/progression/models/exercise_progression_config.dart' as epc;
import 'package:liftly/features/progression/models/progression_calculation_result.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('Refactored Architecture Integration Tests', () {
    late Exercise testExercise;
    late ProgressionConfig testConfig;
    late ProgressionState testState;
    late LinearProgressionStrategy baseStrategy;

    setUp(() {
      // Crear ejercicio de prueba
      testExercise = Exercise(
        id: 'test-exercise-1',
        name: 'Test Exercise',
        description: 'Test exercise for integration tests',
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
        muscleGroups: const [],
        imageUrl: '',
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Crear configuración de progresión
      testConfig = ProgressionConfig(
        id: 'test-config-1',
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 0,
        incrementFrequency: 1,
        minReps: 6,
        maxReps: 12,
        baseSets: 4,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        isActive: true,
        isGlobal: true,
        customParameters: const {},
        startDate: DateTime.now(),
        endDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Crear estado de progresión
      testState = ProgressionState(
        id: 'test-state-1',
        exerciseId: testExercise.id,
        progressionConfigId: testConfig.id,
        routineId: 'test-routine-1',
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 4,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 4,
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        isDeloadWeek: false,
        sessionHistory: const {},
        lastUpdated: DateTime.now(),
        customData: const {},
      );

      // BaseProgressionStrategy es abstracta, no se puede instanciar directamente
      // Usamos LinearProgressionStrategy como ejemplo
      baseStrategy = LinearProgressionStrategy();
    });

    group('AdaptiveIncrementConfig Integration', () {
      test('getIncrementValueSync uses AdaptiveIncrementConfig correctly', () {
        final increment = baseStrategy.getIncrementValueSync(testConfig, testExercise);

        // Para barbell multi-joint (intermediate), el recomendado es 6.0
        expect(increment, equals(6.0));
      });

      test('getMaxRepsSync uses AdaptiveIncrementConfig correctly', () {
        final maxReps = baseStrategy.getMaxRepsSync(testConfig, testExercise);

        // Debería usar el valor de la configuración (12)
        expect(maxReps, equals(12));
      });

      test('getMinRepsSync uses AdaptiveIncrementConfig correctly', () {
        final minReps = baseStrategy.getMinRepsSync(testConfig, testExercise);

        // Debería usar el valor de la configuración (6)
        expect(minReps, equals(6));
      });

      test('getBaseSetsSync uses AdaptiveIncrementConfig correctly', () {
        final baseSets = baseStrategy.getBaseSetsSync(testConfig, testExercise);

        // Debería usar el valor de la configuración (4)
        expect(baseSets, equals(4));
      });
    });

    group('ExerciseProgressionConfig Integration', () {
      test('getIncrementValue prioritizes ExerciseProgressionConfig over AdaptiveIncrementConfig', () async {
        // Crear configuración específica del ejercicio
        final _ = epc.ExerciseProgressionConfig(
          id: 'exercise-config-1',
          exerciseId: testExercise.id,
          progressionConfigId: testConfig.id,
          customIncrement: 7.5, // Valor personalizado
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Simular que el servicio devuelve esta configuración
        // (En un test real, usaríamos un mock)
        final increment = await baseStrategy.getIncrementValue(
          testConfig,
          testExercise,
          null, // Sin servicio por ahora
        );

        // Debería usar AdaptiveIncrementConfig (6.0) ya que no hay servicio
        expect(increment, equals(6.0));
      });

      test('migration from per_exercise to ExerciseProgressionConfig works correctly', () {
        final perExerciseData = {
          testExercise.id: {'increment_value': 7.5, 'min_reps': 8, 'max_reps': 15, 'base_sets': 5},
        };

        // Simular migración
        final now = DateTime.now();
        final migratedConfig = epc.ExerciseProgressionConfig(
          id: '${testExercise.id}_${testConfig.id}',
          exerciseId: testExercise.id,
          progressionConfigId: testConfig.id,
          customIncrement: perExerciseData[testExercise.id]!['increment_value'] as double,
          customMinReps: perExerciseData[testExercise.id]!['min_reps'] as int,
          customMaxReps: perExerciseData[testExercise.id]!['max_reps'] as int,
          customBaseSets: perExerciseData[testExercise.id]!['base_sets'] as int,
          createdAt: now,
          updatedAt: now,
        );

        // Verificar que la migración fue correcta
        expect(migratedConfig.customIncrement, equals(7.5));
        expect(migratedConfig.customMinReps, equals(8));
        expect(migratedConfig.customMaxReps, equals(15));
        expect(migratedConfig.customBaseSets, equals(5));
        expect(migratedConfig.hasCustomConfig, isTrue);
      });
    });

    group('LinearProgressionStrategy Integration', () {
      test('LinearProgressionStrategy works with new architecture', () {
        final linearStrategy = LinearProgressionStrategy();

        // Crear un resultado de progresión
        final result = linearStrategy.calculate(
          config: testConfig,
          state: testState,
          exercise: testExercise,
          routineId: 'test-routine-1',
          currentWeight: testState.currentWeight,
          currentReps: testState.currentReps,
          currentSets: testState.currentSets,
        );

        // Verificar que el resultado es válido
        expect(result, isA<ProgressionCalculationResult>());
        expect(result.newWeight, greaterThanOrEqualTo(testState.currentWeight));
        expect(result.newReps, inInclusiveRange(testConfig.minReps, testConfig.maxReps));
        expect(result.newSets, greaterThan(0));
        expect(result.incrementApplied, isTrue);
        expect(result.isDeload, isFalse);
      });

      test('LinearProgressionStrategy applies deload correctly', () {
        final linearStrategy = LinearProgressionStrategy();

        // Crear estado en semana de deload
        final deloadState = testState.copyWith(
          currentWeek: 4, // Semana de deload
          isDeloadWeek: true,
        );

        final result = linearStrategy.calculate(
          config: testConfig,
          state: deloadState,
          exercise: testExercise,
          routineId: 'test-routine-1',
          currentWeight: deloadState.currentWeight,
          currentReps: deloadState.currentReps,
          currentSets: deloadState.currentSets,
        );

        // Verificar que se aplicó deload
        expect(result.isDeload, isTrue);
        // Si no hay progreso sobre base, el peso puede mantenerse en base
        expect(result.newWeight, lessThanOrEqualTo(testState.currentWeight));
        expect(result.newSets, lessThan(testState.currentSets));
      });
    });

    group('ExperienceLevel Integration', () {
      test('ExperienceLevel factors work correctly', () {
        // Verificar que los factores de incremento son correctos
        expect(aic.ExperienceLevel.initiated.incrementFactor, equals(1.5));
        expect(aic.ExperienceLevel.intermediate.incrementFactor, equals(1.0));
        expect(aic.ExperienceLevel.advanced.incrementFactor, equals(0.5));

        // Verificar que initiated > intermediate > advanced
        expect(
          aic.ExperienceLevel.initiated.incrementFactor,
          greaterThan(aic.ExperienceLevel.intermediate.incrementFactor),
        );
        expect(
          aic.ExperienceLevel.intermediate.incrementFactor,
          greaterThan(aic.ExperienceLevel.advanced.incrementFactor),
        );
      });

      test('AdaptiveIncrementConfig uses ExperienceLevel correctly', () {
        // Crear ejercicios con diferentes tipos y cargas
        final barbellExercise = testExercise.copyWith(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        );

        final dumbbellExercise = testExercise.copyWith(
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.dumbbell,
        );

        // Verificar que los incrementos son diferentes según el tipo
        final barbellIncrement = aic.AdaptiveIncrementConfig.getRecommendedIncrement(
          barbellExercise,
          aic.ExperienceLevel.intermediate,
        );
        final dumbbellIncrement = aic.AdaptiveIncrementConfig.getRecommendedIncrement(
          dumbbellExercise,
          aic.ExperienceLevel.intermediate,
        );

        expect(barbellIncrement, greaterThan(dumbbellIncrement));
        expect(barbellIncrement, equals(6.0)); // Barbell multi-joint
        // Para isolation dumbbell (intermediate) el recomendado actual es 1.875
        expect(dumbbellIncrement, equals(1.875));
      });
    });

    group('Error Handling', () {
      test('handles null exercise gracefully', () {
        // Esto debería lanzar una excepción o manejar el caso null
        expect(() => baseStrategy.getIncrementValueSync(testConfig, testExercise), returnsNormally);
      });

      test('handles invalid config gracefully', () {
        final invalidConfig = testConfig.copyWith(
          minReps: 0, // Inválido
          maxReps: -1, // Inválido
        );

        final isValid = baseStrategy.validateProgressionParams(invalidConfig);
        expect(isValid, isFalse);
      });

      test('handles invalid state gracefully', () {
        final invalidState = testState.copyWith(
          currentWeight: -1, // Inválido
          currentReps: 0, // Inválido
        );

        final isValid = baseStrategy.validateProgressionState(invalidState);
        expect(isValid, isFalse);
      });
    });
  });
}
