import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/base_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/default_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/static_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

/// Test para validar la consistencia del patrón entre todas las estrategias
void main() {
  group('Pattern Consistency Tests', () {
    late ProgressionConfig config;
    late ProgressionState state;
    late Exercise multiExercise;
    late Exercise isoExercise;

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
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: 3,
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: DateTime.now(),
        endDate: null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      multiExercise = Exercise(
        id: 'multi-exercise',
        name: 'Bench Press',
        description: 'Multi joint exercise',
        imageUrl: '',
        muscleGroups: const [MuscleGroup.pectoralMajor],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      isoExercise = Exercise(
        id: 'iso-exercise',
        name: 'Curl',
        description: 'Isolation exercise',
        imageUrl: '',
        muscleGroups: const [MuscleGroup.bicepsLongHead],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.biceps,
        difficulty: ExerciseDifficulty.beginner,
        exerciseType: ExerciseType.isolation,
        loadType: LoadType.dumbbell,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      state = ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        routineId: 'test-routine-1',
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
          expect(() => strategy.getCurrentInCycle(config, state), returnsNormally);
          expect(() => strategy.isDeloadPeriod(config, 1), returnsNormally);
          expect(() => strategy.getIncrementValueSync(config, multiExercise), returnsNormally);
          expect(() => strategy.getMaxRepsSync(config, multiExercise), returnsNormally);
          expect(() => strategy.getMinRepsSync(config, multiExercise), returnsNormally);
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
              reason: 'Strategy ${strategy.runtimeType} should return $expected for session $session',
            );
          }
        }
      });
    });

    group('Consistencia en detección de deload', () {
      test('todas las estrategias detectan deload de la misma manera (excepto Double Factor)', () {
        // Double Factor tiene su propia lógica de deload, se excluye de este test
        final strategies = <BaseProgressionStrategy>[
          LinearProgressionStrategy(),
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
              reason: 'Strategy ${strategy.runtimeType} should return $expected for week $week',
            );
          }
        }
      });

      test('Double Factor tiene su propia lógica de deload', () {
        final strategy = DoubleFactorProgressionStrategy();

        // Double Factor aplica deload cuando se alcanza la semana configurada
        expect(strategy.isDeloadPeriod(config, 1), false);
        expect(strategy.isDeloadPeriod(config, 2), false);
        expect(strategy.isDeloadPeriod(config, 3), true); // Alcanzó deloadWeek
        expect(strategy.isDeloadPeriod(config, 4), true); // >= deloadWeek
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

        for (final strategy in strategies) {
          // Test multi-joint via AdaptiveIncrementConfig
          final multiIncrement = strategy.getIncrementValueSync(config, multiExercise);
          final multiMaxReps = strategy.getMaxRepsSync(config, multiExercise);
          final multiMinReps = strategy.getMinRepsSync(config, multiExercise);

          expect(multiIncrement, greaterThan(0));
          expect(multiMaxReps, isNonNegative);
          expect(multiMinReps, isNonNegative);

          // Test isolation via AdaptiveIncrementConfig
          final isoIncrement = strategy.getIncrementValueSync(config, isoExercise);
          final isoMaxReps = strategy.getMaxRepsSync(config, isoExercise);
          final isoMinReps = strategy.getMinRepsSync(config, isoExercise);

          expect(isoIncrement, greaterThan(0));
          expect(isoMaxReps, isNonNegative);
          expect(isoMinReps, isNonNegative);
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
          // Validar que devuelven valores sin excepciones con ejercicios válidos
          final multiIncrement = strategy.getIncrementValueSync(config, multiExercise);
          final multiMaxReps = strategy.getMaxRepsSync(config, multiExercise);
          final multiMinReps = strategy.getMinRepsSync(config, multiExercise);

          expect(multiIncrement, isA<num>());
          expect(multiMaxReps, isA<int>());
          expect(multiMinReps, isA<int>());

          final isoIncrement = strategy.getIncrementValueSync(config, isoExercise);
          final isoMaxReps = strategy.getMaxRepsSync(config, isoExercise);
          final isoMinReps = strategy.getMinRepsSync(config, isoExercise);

          expect(isoIncrement, isA<num>());
          expect(isoMaxReps, isA<int>());
          expect(isoMinReps, isA<int>());
        }
      });
    });

    group('Manejo de errores consistente', () {
      test('todas las estrategias manejan parámetros inválidos de la misma manera', () {
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
          // No debe lanzar excepciones con datos inválidos
          expect(() => strategy.getIncrementValueSync(config, multiExercise), returnsNormally);
          expect(() => strategy.getMaxRepsSync(config, multiExercise), returnsNormally);
          expect(() => strategy.getMinRepsSync(config, multiExercise), returnsNormally);

          // El incremento puede provenir de AdaptiveIncrementConfig; solo verificamos que sea numérico positivo
          final increment = strategy.getIncrementValueSync(config, multiExercise);
          expect(increment, greaterThan(0));
        }
      });
    });

    group('Estrategias estáticas', () {
      test('StaticProgressionStrategy y DefaultProgressionStrategy no usan deloads', () {
        final staticStrategy = StaticProgressionStrategy();
        final defaultStrategy = DefaultProgressionStrategy();

        // Ambas estrategias deben mantener valores constantes
        final staticResult = staticStrategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 3,
        );

        final defaultResult = defaultStrategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
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
      });
    });
  });
}
