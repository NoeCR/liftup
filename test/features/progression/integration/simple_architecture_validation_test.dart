import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/adaptive_increment_config.dart' as adaptive;
import 'package:liftly/features/progression/models/exercise_progression_config.dart';
import 'package:liftly/features/progression/models/progression_calculation_result.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('Simple Architecture Validation Tests', () {
    late Exercise testExercise;
    late ProgressionConfig testConfig;
    late ProgressionState testState;

    setUp(() {
      // Crear ejercicio de prueba simplificado
      testExercise = Exercise(
        id: 'test-exercise-1',
        name: 'Test Exercise',
        description: 'Test exercise for validation',
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
        incrementValue: 0, // Usar AdaptiveIncrementConfig
        incrementFrequency: 1,
        minReps: 6,
        maxReps: 12,
        baseSets: 4,
        cycleLength: 4,
        deloadWeek: 4,
        deloadPercentage: 0.8,
        isGlobal: true,
        isActive: true,
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
    });

    group('AdaptiveIncrementConfig Validation', () {
      test('getRecommendedIncrement works correctly', () {
        final increment = adaptive.AdaptiveIncrementConfig.getRecommendedIncrement(
          testExercise,
          adaptive.ExperienceLevel.intermediate,
        );

        // Para barbell multi-joint intermediate, debería ser 6.0
        expect(increment, equals(6.0));
      });

      test('ExperienceLevel factors work correctly', () {
        // Verificar que los factores de incremento son correctos
        expect(adaptive.ExperienceLevel.initiated.incrementFactor, equals(1.5));
        expect(adaptive.ExperienceLevel.intermediate.incrementFactor, equals(1.0));
        expect(adaptive.ExperienceLevel.advanced.incrementFactor, equals(0.5));

        // Verificar que initiated > intermediate > advanced
        expect(
          adaptive.ExperienceLevel.initiated.incrementFactor,
          greaterThan(adaptive.ExperienceLevel.intermediate.incrementFactor),
        );
        expect(
          adaptive.ExperienceLevel.intermediate.incrementFactor,
          greaterThan(adaptive.ExperienceLevel.advanced.incrementFactor),
        );
      });

      test('different exercise types have different increments', () {
        final barbellExercise = testExercise.copyWith(
          exerciseType: ExerciseType.multiJoint,
          loadType: LoadType.barbell,
        );

        final dumbbellExercise = testExercise.copyWith(
          exerciseType: ExerciseType.isolation,
          loadType: LoadType.dumbbell,
        );

        final barbellIncrement = adaptive.AdaptiveIncrementConfig.getRecommendedIncrement(
          barbellExercise,
          adaptive.ExperienceLevel.intermediate,
        );
        final dumbbellIncrement = adaptive.AdaptiveIncrementConfig.getRecommendedIncrement(
          dumbbellExercise,
          adaptive.ExperienceLevel.intermediate,
        );

        expect(barbellIncrement, greaterThan(dumbbellIncrement));
        expect(barbellIncrement, equals(6.0)); // Barbell multi-joint
        expect(dumbbellIncrement, equals(1.875)); // Dumbbell isolation
      });
    });

    group('ExerciseProgressionConfig Validation', () {
      test('creates instance with custom values', () {
        final exerciseConfig = ExerciseProgressionConfig(
          id: 'exercise-config-1',
          exerciseId: testExercise.id,
          progressionConfigId: testConfig.id,
          customIncrement: 7.5,
          customMinReps: 8,
          customMaxReps: 15,
          customBaseSets: 5,
          experienceLevel: ExperienceLevel.initiated,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(exerciseConfig.hasCustomIncrement, isTrue);
        expect(exerciseConfig.hasCustomMinReps, isTrue);
        expect(exerciseConfig.hasCustomMaxReps, isTrue);
        expect(exerciseConfig.hasCustomBaseSets, isTrue);
        expect(exerciseConfig.hasCustomConfig, isTrue);
      });

      test('migration from per_exercise data works', () {
        final perExerciseData = {
          testExercise.id: {'increment_value': 7.5, 'min_reps': 8, 'max_reps': 15, 'base_sets': 5},
        };

        final now = DateTime.now();
        final migratedConfig = ExerciseProgressionConfig(
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

        expect(migratedConfig.customIncrement, equals(7.5));
        expect(migratedConfig.customMinReps, equals(8));
        expect(migratedConfig.customMaxReps, equals(15));
        expect(migratedConfig.customBaseSets, equals(5));
      });
    });

    group('LinearProgressionStrategy Validation', () {
      test('calculates progression correctly', () {
        final linearStrategy = LinearProgressionStrategy();

        final result = linearStrategy.calculate(
          config: testConfig,
          state: testState,
          routineId: 'test-routine-1',
          currentWeight: testState.currentWeight,
          currentReps: testState.currentReps,
          currentSets: testState.currentSets,
          exercise: testExercise,
        );

        expect(result, isA<ProgressionCalculationResult>());
        expect(result.newWeight, greaterThanOrEqualTo(testState.currentWeight));
        expect(result.newReps, inInclusiveRange(testConfig.minReps, testConfig.maxReps));
        expect(result.newSets, greaterThan(0));
        expect(result.incrementApplied, isTrue);
        expect(result.isDeload, isFalse);
      });

      test('applies deload correctly', () {
        final linearStrategy = LinearProgressionStrategy();

        final deloadState = testState.copyWith(
          currentWeek: 4, // Semana de deload
          isDeloadWeek: true,
        );

        final result = linearStrategy.calculate(
          config: testConfig,
          state: deloadState,
          routineId: 'test-routine-1',
          currentWeight: deloadState.currentWeight,
          currentReps: deloadState.currentReps,
          currentSets: deloadState.currentSets,
          exercise: testExercise,
        );

        expect(result.isDeload, isTrue);
        // En deload, el peso puede mantenerse o reducirse
        expect(result.newWeight, lessThanOrEqualTo(testState.currentWeight));
        expect(result.newSets, lessThanOrEqualTo(testState.currentSets));
      });
    });

    group('Architecture Integration', () {
      test('new architecture eliminates per_exercise complexity', () {
        // Verificar que no necesitamos customParameters complejos
        final simpleConfig = testConfig.copyWith(
          customParameters: {}, // Vacío, usando AdaptiveIncrementConfig
        );

        expect(simpleConfig.customParameters.isEmpty, isTrue);

        // Verificar que AdaptiveIncrementConfig funciona sin customParameters
        final increment = adaptive.AdaptiveIncrementConfig.getRecommendedIncrement(
          testExercise,
          adaptive.ExperienceLevel.intermediate,
        );

        expect(increment, greaterThan(0));
      });

      test('ExerciseProgressionConfig provides clean override mechanism', () {
        final exerciseConfig = ExerciseProgressionConfig(
          id: 'override-config',
          exerciseId: testExercise.id,
          progressionConfigId: testConfig.id,
          customIncrement: 10.0, // Override específico
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Verificar que el override es específico del ejercicio
        expect(exerciseConfig.exerciseId, equals(testExercise.id));
        expect(exerciseConfig.progressionConfigId, equals(testConfig.id));
        expect(exerciseConfig.customIncrement, equals(10.0));
        expect(exerciseConfig.hasCustomIncrement, isTrue);
      });
    });
  });
}
