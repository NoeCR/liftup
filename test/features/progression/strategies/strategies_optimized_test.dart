import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';

void main() {
  group('Estrategias con Nueva Lógica por Objetivo', () {
    late Exercise testExercise;

    ProgressionState createTestState({int session = 1, Map<String, dynamic>? history}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: session,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 3,
        sessionHistory: history ?? const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    setUp(() {
      testExercise = Exercise(
        id: '1',
        name: 'Squat',
        description: 'Back squat exercise',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.quadriceps,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );
    });

    group('AutoregulatedProgressionStrategy', () {
      late AutoregulatedProgressionStrategy strategy;

      setUp(() {
        strategy = AutoregulatedProgressionStrategy();
      });

      test('debería derivar RPE correcto para FUERZA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.autoregulated,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 3,
          maxReps: 6,
          baseSets: 5,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 100.0);
        expect(result.newReps, 6);
        expect(result.newSets, 3);
        expect(result.reason, contains('RPE'));
      });

      test('debería derivar RPE correcto para HIPERTROFIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.autoregulated,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 98.125);
        expect(result.newReps, 8);
        expect(result.newSets, 3);
        expect(result.reason, contains('RPE'));
      });

      test('debería mantener compatibilidad con customParameters', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.autoregulated,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {
            'target_rpe': 9.0, // Valor personalizado
            'rpe_threshold': 0.3, // Valor personalizado
            'target_reps': 12, // Valor personalizado
          },
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 98.125);
        expect(result.newReps, 8);
        expect(result.newSets, 3);
        expect(result.reason, contains('RPE'));
      });
    });

    group('SteppedProgressionStrategy', () {
      late SteppedProgressionStrategy strategy;

      setUp(() {
        strategy = SteppedProgressionStrategy();
      });

      test('debería derivar semanas de acumulación correctas para FUERZA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.stepped,
          unit: ProgressionUnit.week,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 3,
          maxReps: 6,
          baseSets: 5,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 103.75);
        expect(result.newReps, 5);
        expect(result.newSets, 5);
        expect(result.reason, contains('Stepped progression'));
      });

      test('debería derivar semanas de acumulación correctas para HIPERTROFIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.stepped,
          unit: ProgressionUnit.week,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 103.75);
        expect(result.newReps, 8);
        expect(result.newSets, 4);
        expect(result.reason, contains('Stepped progression'));
      });

      test('debería derivar semanas de acumulación correctas para RESISTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.stepped,
          unit: ProgressionUnit.week,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.volume,
          incrementValue: 1.25,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 15,
          maxReps: 25,
          baseSets: 2,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 50.0,
          currentReps: 20,
          currentSets: 2,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 51.0);
        expect(result.newReps, 20);
        expect(result.newSets, 2);
        expect(result.reason, contains('Stepped progression'));
      });

      test('debería mantener compatibilidad con customParameters', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.stepped,
          unit: ProgressionUnit.week,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {
            'accumulation_weeks': 5, // Valor personalizado
          },
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 103.75);
        expect(result.newReps, 8);
        expect(result.newSets, 4);
        expect(result.reason, contains('Stepped progression'));
      });
    });

    group('OverloadProgressionStrategy', () {
      late OverloadProgressionStrategy strategy;

      setUp(() {
        strategy = OverloadProgressionStrategy();
      });

      test('debería derivar tipo de overload correcto para FUERZA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.overload,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 3,
          maxReps: 6,
          baseSets: 5,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 5,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 103.9375);
        expect(result.newReps, 5);
        expect(result.newSets, 3);
        expect(result.reason, contains('Overload progression'));
      });

      test('debería derivar tipo de overload correcto para HIPERTROFIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.overload,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 100.0);
        expect(result.newReps, 8);
        expect(result.newSets, 3);
        expect(result.reason, contains('Overload progression'));
      });

      test('debería derivar tipo de overload correcto para RESISTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.overload,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.reps,
          secondaryTarget: ProgressionTarget.volume,
          incrementValue: 1.25,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 15,
          maxReps: 25,
          baseSets: 2,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 50.0,
          currentReps: 20,
          currentSets: 2,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 50.0);
        expect(result.newReps, 20);
        expect(result.newSets, 3);
        expect(result.reason, contains('Overload progression'));
      });

      test('debería derivar tipo de overload correcto para POTENCIA', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.overload,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.weight,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 5.0,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {},
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 1,
          maxReps: 5,
          baseSets: 6,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 120.0,
          currentReps: 3,
          currentSets: 6,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 123.9375);
        expect(result.newReps, 3);
        expect(result.newSets, 3);
        expect(result.reason, contains('Overload progression'));
      });

      test('debería mantener compatibilidad con customParameters', () {
        final config = ProgressionConfig(
          id: 'test',
          isGlobal: true,
          type: ProgressionType.overload,
          unit: ProgressionUnit.session,
          primaryTarget: ProgressionTarget.volume,
          secondaryTarget: ProgressionTarget.reps,
          incrementValue: 2.5,
          incrementFrequency: 1,
          cycleLength: 4,
          deloadWeek: 0,
          deloadPercentage: 0.9,
          customParameters: {
            'overload_type': 'intensity', // Valor personalizado
            'overload_rate': 0.2, // Valor personalizado
          },
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          minReps: 6,
          maxReps: 12,
          baseSets: 4,
        );

        final result = strategy.calculate(
          config: config,
          exercise: testExercise,
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
          state: createTestState(),
          routineId: 'routine1',
          isExerciseLocked: false,
        );

        expect(result.newWeight, 104.5);
        expect(result.newReps, 8);
        expect(result.newSets, 3);
        expect(result.reason, contains('Overload progression'));
      });
    });
  });
}
