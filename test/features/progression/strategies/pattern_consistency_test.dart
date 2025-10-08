import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/static_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/default_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/base_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';

/// Test para validar la consistencia del patrón entre todas las estrategias
void main() {
  group('Pattern Consistency Tests', () {
    late ProgressionConfig config;
    late ProgressionState state;

    setUp(() {
      config = ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 3,
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: DateTime.now(),
        endDate: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      state = ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    });

    group('Herencia de BaseProgressionStrategy', () {
      test('todas las estrategias extienden BaseProgressionStrategy', () {
        final strategies = [
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
          StaticProgressionStrategy(),
          DefaultProgressionStrategy(),
          ReverseProgressionStrategy(),
          OverloadProgressionStrategy(),
          AutoregulatedProgressionStrategy(),
        ];

        for (final strategy in strategies) {
          expect(strategy, isA<BaseProgressionStrategy>());
        }
      });
    });

    group('Métodos comunes disponibles', () {
      test('todas las estrategias tienen acceso a métodos helper comunes', () {
        final strategies = <BaseProgressionStrategy>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
          StaticProgressionStrategy(),
          DefaultProgressionStrategy(),
          ReverseProgressionStrategy(),
          OverloadProgressionStrategy(),
          AutoregulatedProgressionStrategy(),
        ];

        for (final strategy in strategies) {
          // Verificar que pueden acceder a métodos helper
          expect(
            () => strategy.getCurrentInCycle(config, state),
            returnsNormally,
          );
          expect(() => strategy.isDeloadPeriod(config, 1), returnsNormally);
          expect(() => strategy.getIncrementValue(config), returnsNormally);
          expect(() => strategy.getMaxReps(config), returnsNormally);
          expect(() => strategy.getMinReps(config), returnsNormally);
        }
      });
    });

    group('Consistencia en cálculo de ciclos', () {
      test('todas las estrategias calculan ciclos de la misma manera', () {
        final strategies = <BaseProgressionStrategy>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
        ];

        // Test diferentes posiciones en el ciclo
        final testCases = [
          {'session': 1, 'expected': 1},
          {'session': 2, 'expected': 2},
          {'session': 4, 'expected': 4},
          {'session': 5, 'expected': 1}, // Reinicia ciclo
          {'session': 8, 'expected': 4},
          {'session': 9, 'expected': 1}, // Reinicia ciclo
        ];

        for (final testCase in testCases) {
          final session = testCase['session'] as int;
          final expected = testCase['expected'] as int;
          final testState = state.copyWith(currentSession: session);

          for (final strategy in strategies) {
            final result = strategy.getCurrentInCycle(config, testState);
            expect(
              result,
              equals(expected),
              reason:
                  'Strategy ${strategy.runtimeType} should return $expected for session $session',
            );
          }
        }
      });
    });

    group('Consistencia en detección de deload', () {
      test('todas las estrategias detectan deload de la misma manera', () {
        final strategies = <BaseProgressionStrategy>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
        ];

        // Test diferentes semanas
        final testCases = [
          {'week': 1, 'expected': false},
          {'week': 2, 'expected': false},
          {'week': 3, 'expected': true}, // deloadWeek = 3
          {'week': 4, 'expected': false},
        ];

        for (final testCase in testCases) {
          final week = testCase['week'] as int;
          final expected = testCase['expected'] as bool;

          for (final strategy in strategies) {
            final result = strategy.isDeloadPeriod(config, week);
            expect(
              result,
              equals(expected),
              reason:
                  'Strategy ${strategy.runtimeType} should return $expected for week $week',
            );
          }
        }
      });
    });

    group('Consistencia en incrementos por tipo de ejercicio', () {
      test('todas las estrategias usan la misma lógica de incrementos', () {
        final strategies = <BaseProgressionStrategy>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
          ReverseProgressionStrategy(),
          OverloadProgressionStrategy(),
          AutoregulatedProgressionStrategy(),
        ];

        // Configurar parámetros específicos por tipo
        config = config.copyWith(
          customParameters: {
            'multi_increment_min': 5.0,
            'iso_increment_min': 1.25,
            'multi_reps_max': 8,
            'iso_reps_max': 15,
            'multi_reps_min': 3,
            'iso_reps_min': 8,
          },
        );

        for (final strategy in strategies) {
          // Test multi-joint
          final multiIncrement = strategy.getIncrementValue(
            config,
            exerciseType: ExerciseType.multiJoint,
          );
          final multiMaxReps = strategy.getMaxReps(
            config,
            exerciseType: ExerciseType.multiJoint,
          );
          final multiMinReps = strategy.getMinReps(
            config,
            exerciseType: ExerciseType.multiJoint,
          );

          expect(multiIncrement, equals(5.0));
          expect(multiMaxReps, equals(8));
          expect(multiMinReps, equals(3));

          // Test isolation
          final isoIncrement = strategy.getIncrementValue(
            config,
            exerciseType: ExerciseType.isolation,
          );
          final isoMaxReps = strategy.getMaxReps(
            config,
            exerciseType: ExerciseType.isolation,
          );
          final isoMinReps = strategy.getMinReps(
            config,
            exerciseType: ExerciseType.isolation,
          );

          expect(isoIncrement, equals(1.25));
          expect(isoMaxReps, equals(15));
          expect(isoMinReps, equals(8));
        }
      });
    });

    group('Fallbacks consistentes', () {
      test('todas las estrategias usan los mismos fallbacks por defecto', () {
        final strategies = <BaseProgressionStrategy>[
          LinearProgressionStrategy(),
          DoubleFactorProgressionStrategy(),
          UndulatingProgressionStrategy(),
          SteppedProgressionStrategy(),
          WaveProgressionStrategy(),
          ReverseProgressionStrategy(),
          OverloadProgressionStrategy(),
          AutoregulatedProgressionStrategy(),
        ];

        for (final strategy in strategies) {
          // Test fallbacks para multi-joint
          final multiIncrement = strategy.getIncrementValue(
            config,
            exerciseType: ExerciseType.multiJoint,
          );
          final multiMaxReps = strategy.getMaxReps(
            config,
            exerciseType: ExerciseType.multiJoint,
          );
          final multiMinReps = strategy.getMinReps(
            config,
            exerciseType: ExerciseType.multiJoint,
          );

          expect(multiIncrement, equals(2.5)); // Default para multi-joint
          expect(multiMaxReps, equals(8)); // Default para multi-joint
          expect(multiMinReps, equals(5)); // Default para multi-joint

          // Test fallbacks para isolation
          final isoIncrement = strategy.getIncrementValue(
            config,
            exerciseType: ExerciseType.isolation,
          );
          final isoMaxReps = strategy.getMaxReps(
            config,
            exerciseType: ExerciseType.isolation,
          );
          final isoMinReps = strategy.getMinReps(
            config,
            exerciseType: ExerciseType.isolation,
          );

          expect(isoIncrement, equals(1.25)); // Default para isolation
          expect(isoMaxReps, equals(15)); // Default para isolation
          expect(isoMinReps, equals(8)); // Default para isolation
        }
      });
    });

    group('Manejo de errores consistente', () {
      test(
        'todas las estrategias manejan parámetros inválidos de la misma manera',
        () {
          final strategies = <BaseProgressionStrategy>[
            LinearProgressionStrategy(),
            DoubleFactorProgressionStrategy(),
            UndulatingProgressionStrategy(),
            SteppedProgressionStrategy(),
            WaveProgressionStrategy(),
            ReverseProgressionStrategy(),
            OverloadProgressionStrategy(),
            AutoregulatedProgressionStrategy(),
          ];

          // Configurar parámetros con datos inválidos
          config = config.copyWith(
            customParameters: {
              'per_exercise': 'invalid_data',
              'multi_increment_min': 'not_a_number',
              'increment_value': 3.0, // Fallback válido
            },
          );

          for (final strategy in strategies) {
            // Debe usar fallback global sin lanzar excepciones
            expect(() => strategy.getIncrementValue(config), returnsNormally);
            expect(() => strategy.getMaxReps(config), returnsNormally);
            expect(() => strategy.getMinReps(config), returnsNormally);

            // Debe usar el fallback global
            final increment = strategy.getIncrementValue(config);
            expect(increment, equals(3.0));
          }
        },
      );
    });

    group('Estrategias estáticas', () {
      test(
        'StaticProgressionStrategy y DefaultProgressionStrategy no usan deloads',
        () {
          final staticStrategy = StaticProgressionStrategy();
          final defaultStrategy = DefaultProgressionStrategy();

          // Ambas estrategias deben mantener valores constantes
          final staticResult = staticStrategy.calculate(
            config: config,
            state: state,
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 3,
          );

          final defaultResult = defaultStrategy.calculate(
            config: config,
            state: state,
            currentWeight: 100.0,
            currentReps: 10,
            currentSets: 3,
          );

          expect(staticResult.incrementApplied, isFalse);
          expect(staticResult.newWeight, equals(100.0));
          expect(staticResult.newReps, equals(10));
          expect(staticResult.newSets, equals(3));

          expect(defaultResult.incrementApplied, isFalse);
          expect(defaultResult.newWeight, equals(100.0));
          expect(defaultResult.newReps, equals(10));
          expect(defaultResult.newSets, equals(3));
        },
      );
    });
  });
}
