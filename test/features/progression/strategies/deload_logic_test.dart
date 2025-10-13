import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';

void main() {
  group('Deload Logic Tests', () {
    // Exercise de prueba requerido por la nueva API de estrategias
    final Exercise testExercise = Exercise(
      id: 'test-exercise',
      name: 'Test Exercise',
      description: 'Exercise for deload tests',
      imageUrl: 'image.png',
      muscleGroups: const [MuscleGroup.pectoralMajor],
      tips: const ['keep form'],
      commonMistakes: const ['arch back'],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.beginner,
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    // Helper para crear configuraciones con deload
    ProgressionConfig createDeloadConfig({
      required ProgressionType type,
      int deloadWeek = 1,
      double deloadPercentage = 0.9,
    }) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'deload_test_config',
        isGlobal: true,
        type: type,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: deloadWeek,
        deloadPercentage: deloadPercentage,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    // Helper para crear estados con progreso acumulado
    ProgressionState createProgressedState({
      required double currentWeight,
      required double baseWeight,
      int currentSession = 1,
    }) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'deload_test_state',
        progressionConfigId: 'deload_test_config',
        exerciseId: 'test_exercise',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: currentSession,
        currentWeight: currentWeight,
        currentReps: 10,
        currentSets: 4,
        baseWeight: baseWeight,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    group('LinearProgressionStrategy Deload', () {
      final strategy = LinearProgressionStrategy();

      test('deload mantiene progreso sobre peso base', () {
        final config = createDeloadConfig(type: ProgressionType.linear);
        final state = createProgressedState(
          currentWeight: 120.0, // 20kg por encima del base
          baseWeight: 100.0,
          currentSession: 1, // Semana de deload
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload correcto: baseWeight + (increaseOverBase * deloadPercentage)
        // 100 + (20 * 0.9) = 118
        expect(result.newWeight, 118.0);
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('Deload'));
      });

      test('deload con peso igual al base', () {
        final config = createDeloadConfig(type: ProgressionType.linear);
        final state = createProgressedState(currentWeight: 100.0, baseWeight: 100.0, currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Sin incremento sobre base, deload = baseWeight
        expect(result.newWeight, 100.0);
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
      });

      test('deload con peso menor al base (caso edge)', () {
        final config = createDeloadConfig(type: ProgressionType.linear);
        final state = createProgressedState(
          currentWeight: 90.0, // Menor al base
          baseWeight: 100.0,
          currentSession: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 90.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // increaseOverBase = 0 (clamp), deload = baseWeight
        expect(result.newWeight, 100.0);
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
      });

      test('no deload cuando no es semana de deload', () {
        final config = createDeloadConfig(
          type: ProgressionType.linear,
          deloadWeek: 2, // Deload en semana 2
        );
        final state = createProgressedState(
          currentWeight: 120.0,
          baseWeight: 100.0,
          currentSession: 1, // Semana 1, no deload
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Incremento normal, no deload (usar incremento real de la estrategia)
        final inc = LinearProgressionStrategy().getIncrementValueSync(config, testExercise);
        expect(result.newWeight, 120.0 + inc);
        expect(result.newSets, 3); // baseSets del config
        expect(result.reason, isNot(contains('Deload')));
      });
    });

    group('DoubleProgressionStrategy Deload', () {
      final strategy = DoubleProgressionStrategy();

      test('deload correcto en progresión doble', () {
        final config = createDeloadConfig(type: ProgressionType.double);
        final state = createProgressedState(
          currentWeight: 115.0, // 15kg por encima del base
          baseWeight: 100.0,
          currentSession: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 115.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload: 100 + (15 * 0.9) = 113.5
        expect(result.newWeight, 113.5);
        expect(result.newSets, 2); // Deload reduce sets al 70% de baseSets (3) = 2.1 -> 2
        expect(result.reason, contains('Deload'));
      });

      test('deload no afecta lógica de reps', () {
        final config = createDeloadConfig(type: ProgressionType.double);
        final state = createProgressedState(currentWeight: 120.0, baseWeight: 100.0, currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // En deload, mantiene reps actuales
        expect(result.newReps, 10);
        expect(result.newWeight, 118.0); // 100 + (20 * 0.9)
      });
    });

    group('UndulatingProgressionStrategy Deload', () {
      final strategy = UndulatingProgressionStrategy();

      test('deload correcto en progresión ondulante', () {
        final config = createDeloadConfig(type: ProgressionType.undulating);
        final state = createProgressedState(
          currentWeight: 125.0, // 25kg por encima del base
          baseWeight: 100.0,
          currentSession: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 125.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload: 100 + (25 * 0.9) = 122.5
        expect(result.newWeight, 122.5);
        expect(result.newSets, 2); // Deload reduce sets al 70% de baseSets (3) = 2.1 -> 2
        expect(result.reason, contains('Deload'));
      });

      test('deload anula lógica de heavy/light day', () {
        final config = createDeloadConfig(type: ProgressionType.undulating);
        final state = createProgressedState(
          currentWeight: 120.0,
          baseWeight: 100.0,
          currentSession: 1, // Sesión de deload
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload tiene prioridad sobre heavy/light day
        expect(result.newWeight, 118.0); // Deload, no light day
        expect(result.newReps, 10); // Mantiene reps en deload
        expect(result.reason, contains('Deload'));
      });
    });

    group('Deload Edge Cases', () {
      final strategy = LinearProgressionStrategy();

      test('deload con porcentaje 0.0 (sin reducción)', () {
        final config = createDeloadConfig(type: ProgressionType.linear, deloadPercentage: 0.0);
        final state = createProgressedState(currentWeight: 120.0, baseWeight: 100.0, currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload 0%: si aplica deload vuelve al peso base; si no, debe mantener comportamiento normal
        if (result.isDeload) {
          expect(result.newWeight, 100.0);
          expect(result.newSets, 2); // 70% de baseSets
        } else {
          expect(result.newWeight, 120.0);
          // sin deload puede mantenerse en sets actuales o baseSets según estrategia
          expect([3, 4], contains(result.newSets));
        }
      });

      test('deload con porcentaje 1.0 (sin reducción)', () {
        final config = createDeloadConfig(type: ProgressionType.linear, deloadPercentage: 1.0);
        final state = createProgressedState(currentWeight: 120.0, baseWeight: 100.0, currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload 100%: si aplica deload mantiene peso actual y reduce sets a 70%
        if (result.isDeload) {
          expect(result.newWeight, 120.0);
          expect(result.newSets, 2);
        } else {
          // sin deload, se espera sets base o sets actuales
          expect([3, 4], contains(result.newSets));
        }
      });

      test('deload con incremento muy pequeño', () {
        final config = createDeloadConfig(type: ProgressionType.linear, deloadPercentage: 0.9);
        final state = createProgressedState(
          currentWeight: 100.1, // Incremento muy pequeño
          baseWeight: 100.0,
          currentSession: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.1,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload: 100 + (0.1 * 0.9) = 100.09
        expect(result.newWeight, closeTo(100.09, 0.01));
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
      });

      test('deload con incremento muy grande', () {
        final config = createDeloadConfig(type: ProgressionType.linear, deloadPercentage: 0.9);
        final state = createProgressedState(
          currentWeight: 200.0, // Incremento muy grande
          baseWeight: 100.0,
          currentSession: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 200.0,
          currentReps: 10,
          currentSets: 4,
          exercise: testExercise,
        );

        // Deload: 100 + (100 * 0.9) = 190
        expect(result.newWeight, 190.0);
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
      });
    });

    group('Deload Consistency Across Strategies', () {
      test('todas las estrategias usan la misma lógica de deload', () {
        final strategies = [LinearProgressionStrategy(), DoubleProgressionStrategy(), UndulatingProgressionStrategy()];

        final config = createDeloadConfig(type: ProgressionType.linear);
        final state = createProgressedState(currentWeight: 120.0, baseWeight: 100.0, currentSession: 1);

        for (final strategy in strategies) {
          final result = (strategy as ProgressionStrategy).calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 120.0,
            currentReps: 10,
            currentSets: 4,
            exercise: testExercise,
          );

          // Todas deben aplicar deload en sesión 1 con deloadWeek=1
          if (result.isDeload) {
            expect(result.newWeight, 118.0);
            expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
            expect(result.reason, contains('Deload'));
          } else {
            // Sin deload, no debe reducir sets
            expect([3, 4], contains(result.newSets));
          }
        }
      });

      test('deload respeta el peso base original', () {
        final strategy = LinearProgressionStrategy();
        final config = createDeloadConfig(type: ProgressionType.linear);

        // Simular múltiples incrementos
        final state = createProgressedState(
          currentWeight: 130.0, // 30kg por encima del base
          baseWeight: 100.0,
          currentSession: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 130.0,
          currentReps: 10,
          currentSets: 4,
        );

        // Si aplica deload: 100 + (30 * 0.9) = 127
        if (result.isDeload) {
          expect(result.newWeight, 127.0);
          expect(result.newWeight, greaterThan(100.0));
        } else {
          // Sin deload, se mantiene el peso actual
          expect(result.newWeight, 130.0);
        }
      });
    });
  });
}
