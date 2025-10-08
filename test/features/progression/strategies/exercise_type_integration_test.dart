import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';

void main() {
  group('Exercise Type Integration Tests', () {
    late ProgressionConfig config;
    late ProgressionState state;
    final now = DateTime.now();

    setUp(() {
      config = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5, // Valor base
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.8,
        customParameters: {
          // Parámetros específicos por tipo de ejercicio
          'multi_increment_min': 5.0, // Incremento para multi-joint
          'iso_increment_min': 1.25, // Incremento para isolation
          'multi_reps_max': 8, // Max reps para multi-joint
          'iso_reps_max': 15, // Max reps para isolation
          'multi_reps_min': 3, // Min reps para multi-joint
          'iso_reps_min': 8, // Min reps para isolation
        },
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      state = ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 5,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 5,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    });

    group('LinearProgressionStrategy', () {
      test(
        'aplica incremento multi_increment_min para ejercicios multi-joint',
        () {
          final strategy = LinearProgressionStrategy();

          final result = strategy.calculate(
            config: config,
            state: state,
            currentWeight: 100.0,
            currentReps: 5,
            currentSets: 3,
            exerciseType: ExerciseType.multiJoint,
          );

          expect(result.newWeight, 105.0); // 100 + 5.0 (multi_increment_min)
          expect(result.incrementApplied, true);
          expect(result.reason, contains('+5.0kg'));
        },
      );

      test('aplica incremento iso_increment_min para ejercicios isolation', () {
        final strategy = LinearProgressionStrategy();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 101.25); // 100 + 1.25 (iso_increment_min)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.25kg'));
      });

      test('usa incrementValue base cuando no hay tipo de ejercicio', () {
        final strategy = LinearProgressionStrategy();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          // exerciseType: null (no especificado)
        );

        expect(result.newWeight, 102.5); // 100 + 2.5 (incrementValue base)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+2.5kg'));
      });
    });

    group('DoubleFactorProgressionStrategy', () {
      test('usa max_reps multi para ejercicios multi-joint', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Configurar reps en el máximo para multi-joint
        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 8, // Máximo para multi-joint
          currentSets: 3,
          exerciseType: ExerciseType.multiJoint,
        );

        expect(result.newWeight, 105.0); // 100 + 5.0 (multi_increment_min)
        expect(result.newReps, 3); // multi_reps_min
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+5.0kg'));
      });

      test('usa max_reps iso para ejercicios isolation', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Configurar reps en el máximo para isolation
        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 15, // Máximo para isolation
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 101.25); // 100 + 1.25 (iso_increment_min)
        expect(result.newReps, 8); // iso_reps_min
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.25kg'));
      });

      test('incrementa reps dentro del rango multi-joint', () {
        final strategy = DoubleFactorProgressionStrategy();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 5, // Dentro del rango multi-joint (3-8)
          currentSets: 3,
          exerciseType: ExerciseType.multiJoint,
        );

        expect(result.newWeight, 100.0); // No cambia peso
        expect(result.newReps, 6); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('increasing reps'));
      });

      test('incrementa reps dentro del rango isolation', () {
        final strategy = DoubleFactorProgressionStrategy();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10, // Dentro del rango isolation (8-15)
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 100.0); // No cambia peso
        expect(result.newReps, 11); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('increasing reps'));
      });
    });

    group('UndulatingProgressionStrategy', () {
      test('aplica incremento multi en día pesado para multi-joint', () {
        final strategy = UndulatingProgressionStrategy();
        // Semana 1 = día pesado (impar)
        final stateWeek1 = state.copyWith(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: stateWeek1,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.multiJoint,
        );

        expect(result.newWeight, 105.0); // 100 + 5.0 (multi_increment_min)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+5.0kg'));
      });

      test('aplica incremento iso en día pesado para isolation', () {
        final strategy = UndulatingProgressionStrategy();
        // Semana 1 = día pesado (impar)
        final stateWeek1 = state.copyWith(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: stateWeek1,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 101.25); // 100 + 1.25 (iso_increment_min)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.25kg'));
      });

      test(
        'reduce peso con incremento multi en día ligero para multi-joint',
        () {
          final strategy = UndulatingProgressionStrategy();
          // Semana 2 = día ligero (par)
          final stateWeek2 = state.copyWith(currentWeek: 2);

          final result = strategy.calculate(
            config: config,
            state: stateWeek2,
            currentWeight: 100.0,
            currentReps: 5,
            currentSets: 3,
            exerciseType: ExerciseType.multiJoint,
          );

          expect(result.newWeight, 95.0); // 100 - 5.0 (multi_increment_min)
          expect(result.incrementApplied, true);
          expect(result.reason, contains('-5.0kg'));
        },
      );

      test('reduce peso con incremento iso en día ligero para isolation', () {
        final strategy = UndulatingProgressionStrategy();
        // Semana 2 = día ligero (par)
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 98.75); // 100 - 1.25 (iso_increment_min)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-1.25kg'));
      });
    });

    group('SteppedProgressionStrategy', () {
      test('acumula incremento multi para ejercicios multi-joint', () {
        final strategy = SteppedProgressionStrategy();
        // Semana 2 de acumulación
        final stateWeek2 = state.copyWith(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: stateWeek2,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.multiJoint,
        );

        // Acumulación: baseWeight + (increment * week)
        // 100 + (5.0 * 2) = 110.0
        expect(result.newWeight, 110.0);
        expect(result.incrementApplied, true);
        expect(result.reason, contains('accumulation phase'));
      });

      test('acumula incremento iso para ejercicios isolation', () {
        final strategy = SteppedProgressionStrategy();
        // Semana 3 de acumulación
        final stateWeek3 = state.copyWith(currentWeek: 3);

        final result = strategy.calculate(
          config: config,
          state: stateWeek3,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        // Acumulación: baseWeight + (increment * week)
        // 100 + (1.25 * 3) = 103.75
        expect(result.newWeight, 103.75);
        expect(result.incrementApplied, true);
        expect(result.reason, contains('accumulation phase'));
      });
    });

    group('WaveProgressionStrategy', () {
      test(
        'aplica incremento multi en semana 1 (alta intensidad) para multi-joint',
        () {
          final strategy = WaveProgressionStrategy();
          // Semana 1 = alta intensidad
          final stateWeek1 = state.copyWith(currentWeek: 1);

          final result = strategy.calculate(
            config: config,
            state: stateWeek1,
            currentWeight: 100.0,
            currentReps: 5,
            currentSets: 3,
            exerciseType: ExerciseType.multiJoint,
          );

          expect(result.newWeight, 105.0); // 100 + 5.0 (multi_increment_min)
          expect(result.incrementApplied, true);
          expect(result.reason, contains('+5.0kg'));
        },
      );

      test(
        'aplica incremento iso en semana 1 (alta intensidad) para isolation',
        () {
          final strategy = WaveProgressionStrategy();
          // Semana 1 = alta intensidad
          final stateWeek1 = state.copyWith(currentWeek: 1);

          final result = strategy.calculate(
            config: config,
            state: stateWeek1,
            currentWeight: 100.0,
            currentReps: 5,
            currentSets: 3,
            exerciseType: ExerciseType.isolation,
          );

          expect(result.newWeight, 101.25); // 100 + 1.25 (iso_increment_min)
          expect(result.incrementApplied, true);
          expect(result.reason, contains('+1.25kg'));
        },
      );

      test(
        'reduce peso con incremento multi en semana 2 (alto volumen) para multi-joint',
        () {
          final strategy = WaveProgressionStrategy();
          // Semana 2 = alto volumen
          final stateWeek2 = state.copyWith(currentWeek: 2);

          final result = strategy.calculate(
            config: config,
            state: stateWeek2,
            currentWeight: 100.0,
            currentReps: 5,
            currentSets: 3,
            exerciseType: ExerciseType.multiJoint,
          );

          // Alto volumen: reduce peso por 30% del incremento
          // 100 - (5.0 * 0.3) = 98.5
          expect(result.newWeight, 98.5);
          expect(result.incrementApplied, true);
          expect(result.reason, contains('-1.5kg'));
        },
      );

      test(
        'reduce peso con incremento iso en semana 2 (alto volumen) para isolation',
        () {
          final strategy = WaveProgressionStrategy();
          // Semana 2 = alto volumen
          final stateWeek2 = state.copyWith(currentWeek: 2);

          final result = strategy.calculate(
            config: config,
            state: stateWeek2,
            currentWeight: 100.0,
            currentReps: 5,
            currentSets: 3,
            exerciseType: ExerciseType.isolation,
          );

          // Alto volumen: reduce peso por 30% del incremento
          // 100 - (1.25 * 0.3) = 99.625
          expect(result.newWeight, 99.625);
          expect(result.incrementApplied, true);
          expect(result.reason, contains('-0.4kg'));
        },
      );
    });

    group('ReverseProgressionStrategy', () {
      test('reduce peso con incremento multi para ejercicios multi-joint', () {
        final strategy = ReverseProgressionStrategy();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.multiJoint,
        );

        expect(result.newWeight, 95.0); // 100 - 5.0 (multi_increment_min)
        expect(result.newReps, 6); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-5.0kg'));
      });

      test('reduce peso con incremento iso para ejercicios isolation', () {
        final strategy = ReverseProgressionStrategy();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 98.75); // 100 - 1.25 (iso_increment_min)
        expect(result.newReps, 6); // Incrementa reps
        expect(result.incrementApplied, true);
        expect(result.reason, contains('-1.25kg'));
      });
    });

    group('AutoregulatedProgressionStrategy', () {
      test('aplica incremento multi cuando RPE es bajo para multi-joint', () {
        final strategy = AutoregulatedProgressionStrategy();
        // Simular RPE bajo (reps realizadas > target)
        final stateWithHistory = state.copyWith(
          sessionHistory: {
            'session_1': {'reps': 12}, // Más reps de las esperadas = RPE bajo
          },
        );

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.multiJoint,
        );

        expect(result.newWeight, 105.0); // 100 + 5.0 (multi_increment_min)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+5.0kg'));
      });

      test('aplica incremento iso cuando RPE es bajo para isolation', () {
        final strategy = AutoregulatedProgressionStrategy();
        // Simular RPE bajo (reps realizadas > target)
        final stateWithHistory = state.copyWith(
          sessionHistory: {
            'session_1': {'reps': 12}, // Más reps de las esperadas = RPE bajo
          },
        );

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          currentWeight: 100.0,
          currentReps: 5,
          currentSets: 3,
          exerciseType: ExerciseType.isolation,
        );

        expect(result.newWeight, 101.25); // 100 + 1.25 (iso_increment_min)
        expect(result.incrementApplied, true);
        expect(result.reason, contains('+1.25kg'));
      });
    });

    group('Fallback Behavior', () {
      test(
        'todas las estrategias usan incrementValue base cuando no hay parámetros específicos',
        () {
          final configWithoutSpecifics = config.copyWith(
            customParameters: {
              'increment_value': 3.0, // Solo valor base
            },
          );

          final strategies = <dynamic>[
            LinearProgressionStrategy(),
            DoubleFactorProgressionStrategy(),
            UndulatingProgressionStrategy(),
            SteppedProgressionStrategy(),
            WaveProgressionStrategy(),
            // ReverseProgressionStrategy(), // Excluida porque reduce peso por diseño
            AutoregulatedProgressionStrategy(),
          ];

          for (final strategy in strategies) {
            // Para DoubleFactorProgressionStrategy, necesitamos reps >= maxReps para que incremente peso
            final currentReps =
                strategy is DoubleFactorProgressionStrategy ? 12 : 5;

            // Para estrategias que alternan, necesitamos estar en fase de incremento
            final testState =
                strategy is UndulatingProgressionStrategy
                    ? state.copyWith(currentWeek: 1) // Semana 1 = día pesado
                    : strategy is WaveProgressionStrategy
                    ? state.copyWith(
                      currentWeek: 1,
                    ) // Semana 1 = alta intensidad
                    : strategy is AutoregulatedProgressionStrategy
                    ? state.copyWith(
                      sessionHistory: {
                        'session_1': {
                          'reps': 12,
                        }, // Más reps de las esperadas = RPE bajo
                      },
                    )
                    : state;

            final result = strategy.calculate(
              config: configWithoutSpecifics,
              state: testState,
              currentWeight: 100.0,
              currentReps: currentReps,
              currentSets: 3,
              exerciseType:
                  ExerciseType
                      .multiJoint, // Tipo no importa sin parámetros específicos
            );

            // Todas deben usar el incrementValue base (3.0)
            expect(result.newWeight, greaterThan(100.0));
            expect(result.incrementApplied, true);
          }
        },
      );

      test(
        'todas las estrategias usan defaults por tipo cuando no hay parámetros personalizados',
        () {
          final configMinimal = config.copyWith(
            customParameters: const {}, // Sin parámetros personalizados
          );

          final strategies = <dynamic>[
            LinearProgressionStrategy(),
            DoubleFactorProgressionStrategy(),
            UndulatingProgressionStrategy(),
            SteppedProgressionStrategy(),
            WaveProgressionStrategy(),
            // ReverseProgressionStrategy(), // Excluida porque reduce peso por diseño
            AutoregulatedProgressionStrategy(),
          ];

          for (final strategy in strategies) {
            // Para DoubleFactorProgressionStrategy, necesitamos reps >= maxReps para que incremente peso
            final currentReps =
                strategy is DoubleFactorProgressionStrategy ? 12 : 5;

            // Para estrategias que alternan, necesitamos estar en fase de incremento
            final testState =
                strategy is UndulatingProgressionStrategy
                    ? state.copyWith(currentWeek: 1) // Semana 1 = día pesado
                    : strategy is WaveProgressionStrategy
                    ? state.copyWith(
                      currentWeek: 1,
                    ) // Semana 1 = alta intensidad
                    : strategy is AutoregulatedProgressionStrategy
                    ? state.copyWith(
                      sessionHistory: {
                        'session_1': {
                          'reps': 12,
                        }, // Más reps de las esperadas = RPE bajo
                      },
                    )
                    : state;

            final result = strategy.calculate(
              config: configMinimal,
              state: testState,
              currentWeight: 100.0,
              currentReps: currentReps,
              currentSets: 3,
              exerciseType: ExerciseType.multiJoint,
            );

            // Deben usar defaults por tipo o incrementValue base
            expect(result.newWeight, greaterThan(100.0));
            expect(result.incrementApplied, true);
          }
        },
      );
    });
  });
}
