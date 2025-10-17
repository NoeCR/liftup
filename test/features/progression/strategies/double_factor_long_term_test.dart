import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_calculation_result.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';

import '../helpers/exercise_mock_factory.dart';

void main() {
  group('DoubleFactorProgressionStrategy - Tests a Largo Plazo', () {
    late DoubleFactorProgressionStrategy strategy;
    late Exercise exercise;

    setUp(() {
      strategy = DoubleFactorProgressionStrategy();
      exercise = ExerciseMockFactory.createExercise();
    });

    /// Helper para crear configuración con modo específico
    ProgressionConfig createConfigWithMode(String mode, {int cycleLength = 6}) {
      return ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.doubleFactor,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: cycleLength,
        deloadWeek: cycleLength,
        deloadPercentage: 0.8,
        customParameters: {
          'double_factor_mode': mode,
          'min_reps': 6,
          'max_reps': 10,
        },
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        minReps: 6,
        maxReps: 10,
        baseSets: 3,
      );
    }

    /// Helper para crear estado de progresión
    ProgressionState createState({
      required int currentInCycle,
      required double baseWeight,
      required int baseReps,
    }) {
      return ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: exercise.id,
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: currentInCycle,
        currentSession: 1,
        currentWeight: baseWeight,
        currentReps: baseReps,
        currentSets: 3,
        baseWeight: baseWeight,
        baseReps: baseReps,
        baseSets: 3,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );
    }

    group('Ciclo Completo - Modo Alternado', () {
      test('simula 2 ciclos completos de 6 semanas cada uno', () {
        final config = createConfigWithMode('alternate', cycleLength: 6);
        double currentWeight = 80.0;
        int currentReps = 6;
        int currentInCycle = 1;

        final results = <ProgressionCalculationResult>[];

        // Simular 2 ciclos completos (12 semanas)
        for (int week = 1; week <= 12; week++) {
          final state = createState(
            currentInCycle: currentInCycle,
            baseWeight: 80.0,
            baseReps: 6,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          results.add(result);

          // Actualizar valores para la siguiente semana
          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Si es deload, resetear ciclo
          if (result.shouldResetCycle) {
            currentInCycle = 1;
          } else {
            currentInCycle++;
          }
        }

        // Verificar patrón de progresión
        expect(results.length, 12);

        // Semana 1 (impar): peso incrementa, reps se mantienen
        expect(
          results[0].newWeight,
          85.0,
        ); // 80.0 + 5.0 (incremento adaptativo para initiated)
        expect(results[0].newReps, 6);
        expect(results[0].reason, contains('increasing weight'));

        // Semana 2 (par): peso se mantiene, reps incrementan
        expect(
          results[1].newWeight,
          85.0,
        ); // Se mantiene el peso de la semana anterior
        expect(results[1].newReps, 7); // 6 + 1
        expect(results[1].reason, contains('increasing reps'));

        // Semana 3 (impar): peso incrementa, reps se mantienen
        expect(results[2].newWeight, 90.0); // 85.0 + 5.0
        expect(results[2].newReps, 7);
        expect(results[2].reason, contains('increasing weight'));

        // Semana 4 (par): peso se mantiene, reps incrementan
        expect(
          results[3].newWeight,
          90.0,
        ); // Se mantiene el peso de la semana anterior
        expect(results[3].newReps, 8); // 7 + 1
        expect(results[3].reason, contains('increasing reps'));

        // Semana 5 (impar): peso incrementa, reps se mantienen
        expect(results[4].newWeight, 95.0); // 90.0 + 5.0
        expect(results[4].newReps, 8);
        expect(results[4].reason, contains('increasing weight'));

        // Semana 6 (par): deload
        expect(results[5].isDeload, true);
        expect(results[5].shouldResetCycle, true);
        expect(results[5].reason, contains('Deload session'));

        // Segundo ciclo - Semana 1 (impar): peso incrementa, reps se mantienen
        expect(
          results[6].newWeight,
          greaterThan(95.0),
        ); // Peso después del deload
        expect(
          results[6].newReps,
          8,
        ); // Reps después del deload (reducidas proporcionalmente)
        expect(results[6].reason, contains('increasing weight'));

        // Verificar que el patrón se repite en el segundo ciclo
        expect(
          results[7].reason,
          contains('increasing reps'),
        ); // Semana 2 del segundo ciclo
        expect(
          results[8].reason,
          contains('increasing weight'),
        ); // Semana 3 del segundo ciclo
        expect(
          results[9].reason,
          contains('increasing reps'),
        ); // Semana 4 del segundo ciclo
        expect(
          results[10].reason,
          contains('increasing weight'),
        ); // Semana 5 del segundo ciclo
        expect(results[11].isDeload, true); // Semana 6 del segundo ciclo
      });
    });

    group('Ciclo Completo - Modo Simultáneo', () {
      test('simula 2 ciclos completos con progresión simultánea', () {
        final config = createConfigWithMode('both', cycleLength: 6);
        double currentWeight = 80.0;
        int currentReps = 6;
        int currentInCycle = 1;

        final results = <ProgressionCalculationResult>[];

        // Simular 2 ciclos completos (12 semanas)
        for (int week = 1; week <= 12; week++) {
          final state = createState(
            currentInCycle: currentInCycle,
            baseWeight: 80.0,
            baseReps: 6,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          results.add(result);

          // Actualizar valores para la siguiente semana
          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Si es deload, resetear ciclo
          if (result.shouldResetCycle) {
            currentInCycle = 1;
          } else {
            currentInCycle++;
          }
        }

        // Verificar que todas las semanas (excepto deload) incrementan peso y reps
        for (int i = 0; i < results.length; i++) {
          if (!results[i].isDeload) {
            expect(results[i].reason, contains('increasing weight'));
            expect(results[i].reason, contains('and reps'));
          }
        }

        // Verificar progresión acumulada
        expect(
          results[0].newWeight,
          85.0,
        ); // 80.0 + 5.0 (incremento adaptativo para initiated)
        expect(results[0].newReps, 7); // 6 + 1
        expect(results[1].newWeight, 90.0); // 85.0 + 5.0
        expect(results[1].newReps, 8); // 7 + 1
        expect(results[2].newWeight, 95.0); // 90.0 + 5.0
        expect(results[2].newReps, 9); // 8 + 1
        expect(results[3].newWeight, 100.0); // 95.0 + 5.0
        expect(results[3].newReps, 10); // 9 + 1 (máximo)
        expect(results[4].newWeight, 105.0); // 100.0 + 5.0
        expect(results[4].newReps, 10); // Se mantiene en máximo

        // Verificar deload
        expect(results[5].isDeload, true);
        expect(results[5].shouldResetCycle, true);
      });
    });

    group('Ciclo Completo - Modo Compuesto', () {
      test('simula 2 ciclos completos con progresión compuesta', () {
        final config = createConfigWithMode('composite', cycleLength: 6);
        double currentWeight = 80.0;
        int currentReps = 6;
        int currentInCycle = 1;

        final results = <ProgressionCalculationResult>[];

        // Simular 2 ciclos completos (12 semanas)
        for (int week = 1; week <= 12; week++) {
          final state = createState(
            currentInCycle: currentInCycle,
            baseWeight: 80.0,
            baseReps: 6,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          results.add(result);

          // Actualizar valores para la siguiente semana
          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Si es deload, resetear ciclo
          if (result.shouldResetCycle) {
            currentInCycle = 1;
          } else {
            currentInCycle++;
          }
        }

        // Verificar que todas las semanas (excepto deload) incrementan peso y reps
        for (int i = 0; i < results.length; i++) {
          if (!results[i].isDeload) {
            expect(results[i].reason, contains('increasing weight'));
            expect(results[i].reason, contains('and reps'));
          }
        }

        // Verificar progresión compuesta (peso + reps con prioridad en peso)
        expect(
          results[0].newWeight,
          85.0,
        ); // 80.0 + 5.0 (incremento adaptativo para initiated)
        expect(
          results[0].newReps,
          8,
        ); // 6 + 2 (5.0 * 0.3 = 1.5, redondeado a 2)
        expect(results[1].newWeight, 90.0); // 85.0 + 5.0
        expect(
          results[1].newReps,
          10,
        ); // 8 + 2 (5.0 * 0.3 = 1.5, redondeado a 2)
        expect(results[2].newWeight, 95.0); // 90.0 + 5.0
        expect(
          results[2].newReps,
          10,
        ); // 10 + 2 = 12, pero se clampa a 10 (máximo)
        expect(results[3].newWeight, 100.0); // 95.0 + 5.0
        expect(results[3].newReps, 10); // Se mantiene en máximo
        expect(results[4].newWeight, 105.0); // 100.0 + 5.0
        expect(results[4].newReps, 10); // Se mantiene en máximo

        // Verificar deload
        expect(results[5].isDeload, true);
        expect(results[5].shouldResetCycle, true);
      });
    });

    group('Comparación de Velocidad de Progresión', () {
      test('compara velocidad de progresión entre modos', () {
        final modes = ['alternate', 'both', 'composite'];
        final finalWeights = <String, double>{};
        final finalReps = <String, int>{};

        for (final mode in modes) {
          final config = createConfigWithMode(mode, cycleLength: 4);
          double currentWeight = 80.0;
          int currentReps = 6;
          int currentInCycle = 1;

          // Simular 1 ciclo completo (4 semanas)
          for (int week = 1; week <= 4; week++) {
            final state = createState(
              currentInCycle: currentInCycle,
              baseWeight: 80.0,
              baseReps: 6,
            );

            final result = strategy.calculate(
              config: config,
              state: state,
              routineId: 'test-routine',
              currentWeight: currentWeight,
              currentReps: currentReps,
              currentSets: 3,
              exercise: exercise,
            );

            // Actualizar valores para la siguiente semana
            currentWeight = result.newWeight;
            currentReps = result.newReps;

            // Si es deload, resetear ciclo
            if (result.shouldResetCycle) {
              currentInCycle = 1;
            } else {
              currentInCycle++;
            }
          }

          finalWeights[mode] = currentWeight;
          finalReps[mode] = currentReps;
        }

        // Verificar que el modo 'both' tiene la progresión más rápida en peso
        expect(
          finalWeights['both']!,
          greaterThanOrEqualTo(finalWeights['alternate']!),
        );
        expect(
          finalWeights['both']!,
          greaterThanOrEqualTo(finalWeights['composite']!),
        );

        // Verificar que todos los modos tienen progresión en reps
        expect(
          finalReps['both']!,
          greaterThan(6),
        ); // Mayor que el valor inicial
        expect(
          finalReps['alternate']!,
          greaterThan(6),
        ); // Mayor que el valor inicial
        expect(
          finalReps['composite']!,
          greaterThan(6),
        ); // Mayor que el valor inicial

        // Verificar que el modo 'composite' tiene progresión intermedia
        expect(
          finalWeights['composite']!,
          greaterThanOrEqualTo(finalWeights['alternate']!),
        );
        expect(
          finalWeights['composite']!,
          lessThanOrEqualTo(finalWeights['both']!),
        );
      });
    });

    group('Límites y Edge Cases', () {
      test('maneja correctamente cuando se alcanzan límites de reps', () {
        final config = createConfigWithMode('both');
        double currentWeight = 80.0;
        int currentReps = 9; // Cerca del máximo
        int currentInCycle = 1;

        final results = <ProgressionCalculationResult>[];

        // Simular 3 semanas
        for (int week = 1; week <= 3; week++) {
          final state = createState(
            currentInCycle: currentInCycle,
            baseWeight: 80.0,
            baseReps: 6,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          results.add(result);

          // Actualizar valores para la siguiente semana
          currentWeight = result.newWeight;
          currentReps = result.newReps;
          currentInCycle++;
        }

        // Verificar que las reps se mantienen en el máximo cuando se alcanza
        expect(results[0].newReps, 10); // 9 + 1 = 10 (máximo)
        expect(results[1].newReps, 10); // Se mantiene en máximo
        expect(results[2].newReps, 10); // Se mantiene en máximo

        // Verificar que el peso sigue incrementando
        expect(results[0].newWeight, 85.0); // 80.0 + 5.0
        expect(results[1].newWeight, 90.0); // 85.0 + 5.0
        expect(results[2].newWeight, 95.0); // 90.0 + 5.0
      });

      test('maneja correctamente deloads múltiples', () {
        final config = createConfigWithMode('alternate', cycleLength: 3);
        double currentWeight = 80.0;
        int currentReps = 6;
        int currentInCycle = 1;

        final results = <ProgressionCalculationResult>[];

        // Simular 6 semanas (2 ciclos de 3 semanas)
        for (int week = 1; week <= 6; week++) {
          final state = createState(
            currentInCycle: currentInCycle,
            baseWeight: 80.0,
            baseReps: 6,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          results.add(result);

          // Actualizar valores para la siguiente semana
          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Si es deload, resetear ciclo
          if (result.shouldResetCycle) {
            currentInCycle = 1;
          } else {
            currentInCycle++;
          }
        }

        // Verificar que hay 2 deloads
        final deloads = results.where((r) => r.isDeload).toList();
        expect(deloads.length, 2);

        // Verificar que ambos deloads resetean el ciclo
        expect(deloads[0].shouldResetCycle, true);
        expect(deloads[1].shouldResetCycle, true);

        // Verificar que el patrón se repite después del primer deload
        expect(
          results[3].reason,
          contains('increasing weight'),
        ); // Semana 1 del segundo ciclo
        expect(
          results[4].reason,
          contains('increasing reps'),
        ); // Semana 2 del segundo ciclo
      });
    });
  });
}
