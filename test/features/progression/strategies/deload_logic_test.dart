import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';

void main() {
  group('Deload Logic Tests', () {
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
        );

        // Deload correcto: baseWeight + (increaseOverBase * deloadPercentage)
        // 100 + (20 * 0.9) = 118
        expect(result.newWeight, 118.0);
        expect(result.newSets, 3); // 4 * 0.7 round
        expect(result.incrementApplied, true);
        expect(result.reason, contains('deload'));
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
        );

        // Sin incremento sobre base, deload = baseWeight
        expect(result.newWeight, 100.0);
        expect(result.newSets, 3);
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
        );

        // increaseOverBase = 0 (clamp), deload = baseWeight
        expect(result.newWeight, 100.0);
        expect(result.newSets, 3);
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
        );

        // Incremento normal, no deload
        expect(result.newWeight, 122.5); // 120 + 2.5
        expect(result.newSets, 4);
        expect(result.reason, isNot(contains('deload')));
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
        );

        // Deload: 100 + (15 * 0.9) = 113.5
        expect(result.newWeight, 113.5);
        expect(result.newSets, 3);
        expect(result.reason, contains('deload'));
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
        );

        // Deload: 100 + (25 * 0.9) = 122.5
        expect(result.newWeight, 122.5);
        expect(result.newSets, 3);
        expect(result.reason, contains('deload'));
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
        );

        // Deload tiene prioridad sobre heavy/light day
        expect(result.newWeight, 118.0); // Deload, no light day
        expect(result.newReps, 10); // Mantiene reps en deload
        expect(result.reason, contains('deload'));
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
        );

        // Deload 0% = vuelve al peso base
        expect(result.newWeight, 100.0);
        expect(result.newSets, 3);
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
        );

        // Deload 100% = mantiene peso actual
        expect(result.newWeight, 120.0);
        expect(result.newSets, 3);
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
        );

        // Deload: 100 + (0.1 * 0.9) = 100.09
        expect(result.newWeight, closeTo(100.09, 0.01));
        expect(result.newSets, 3);
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
        );

        // Deload: 100 + (100 * 0.9) = 190
        expect(result.newWeight, 190.0);
        expect(result.newSets, 3);
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
          );

          // Todas deben aplicar el mismo deload
          expect(result.newWeight, 118.0);
          expect(result.newSets, 3);
          expect(result.reason, contains('deload'));
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

        // Deload debe mantener la proporción del progreso
        // 100 + (30 * 0.9) = 127
        expect(result.newWeight, 127.0);

        // Verificar que no resetea al peso base original
        expect(result.newWeight, greaterThan(100.0));
      });
    });
  });
}
