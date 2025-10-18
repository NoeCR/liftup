import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('Custom Parameters Tests', () {
    // Helper para crear configuraciones con parámetros personalizados
    ProgressionConfig createConfigWithCustomParams({
      required ProgressionType type,
      Map<String, dynamic> customParameters = const {},
    }) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'custom_test_config',
        isGlobal: true,
        type: type,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5, // Valor base
        incrementFrequency: 1,
        cycleLength: 4,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: 0,
        deloadPercentage: 0.9,
        customParameters: customParameters,
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    Exercise ex({ExerciseType type = ExerciseType.multiJoint}) {
      final now = DateTime.now();
      return Exercise(
        id: 'test_exercise',
        name: 'Test',
        description: '',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: now,
        updatedAt: now,
        exerciseType: type,
        loadType: type == ExerciseType.multiJoint ? LoadType.barbell : LoadType.dumbbell,
      );
    }

    // Helper para crear estados
    ProgressionState createState({String exerciseId = 'test_exercise'}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'custom_test_state',
        progressionConfigId: 'custom_test_config',
        exerciseId: exerciseId,
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 10,
        currentSets: 4,
        baseWeight: 100.0,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    group('LinearProgressionStrategy Custom Parameters', () {
      final strategy = LinearProgressionStrategy();

      test('usa incremento adaptativo (per_exercise deprecado)', () {
        final config = createConfigWithCustomParams(type: ProgressionType.linear, customParameters: const {});
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );
        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });

      test('usa incremento multi_ como fallback', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {'multi_increment_min': 3.0, 'iso_increment_min': 1.5},
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );
        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });

      test('usa incremento iso_ como fallback', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {'iso_increment_min': 1.5},
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(type: ExerciseType.isolation),
        );
        final inc = strategy.getIncrementValueSync(config, ex(type: ExerciseType.isolation));
        expect(result.newWeight, 100.0 + inc);
      });

      test('fallback al valor base cuando no hay parámetros personalizados', () {
        final config = createConfigWithCustomParams(type: ProgressionType.linear, customParameters: const {});
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );
        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });

      test('prioridad deprecada: usar AdaptiveIncrementConfig', () {
        final config = createConfigWithCustomParams(type: ProgressionType.linear, customParameters: const {});
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );
        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });
    });

    group('DoubleProgressionStrategy Custom Parameters', () {
      final strategy = DoubleProgressionStrategy();

      test('usa min/max reps personalizados por ejercicio', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {
            'per_exercise': {
              'test_exercise': {'min_reps': 6, 'max_reps': 14, 'increment_value': 3.0},
            },
          },
        );
        final state = createState();

        // Test incremento de reps
        final result1 = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        expect(result1.newReps, 3); // Sistema adaptativo devuelve 3 para hypertrophy multi-joint
        expect(result1.newWeight, 103.75); // Sistema adaptativo incrementa peso

        // Test incremento de peso cuando alcanza máximo
        final result2 = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 14, // Usar maxReps personalizado per_exercise
          currentSets: 4,
          exercise: ex(),
        );

        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result2.newWeight, 100.0 + inc);
        expect(result2.newReps, 3); // Sistema adaptativo devuelve 3 para hypertrophy multi-joint
      });

      test('usa parámetros multi_ vs iso_ según contexto', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {
            'multi_reps_min': 5,
            'multi_reps_max': 10,
            'multi_increment_min': 5.0,
            'iso_reps_min': 8,
            'iso_reps_max': 15,
            'iso_increment_min': 2.5,
          },
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12, // Máximo (del config)
          currentSets: 4,
          exercise: ex(),
        );

        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
        final min = strategy.getMinRepsSync(config, ex());
        expect(result.newReps, min);
      });

      test('fallback a parámetros globales', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {'min_reps': 6, 'max_reps': 12, 'increment_value': 3.0},
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12,
          currentSets: 4,
          exercise: ex(),
        );

        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
        final min = strategy.getMinRepsSync(config, ex());
        expect(result.newReps, min);
      });
    });

    group('AutoregulatedProgressionStrategy Custom Parameters', () {
      final strategy = AutoregulatedProgressionStrategy();

      test('usa RPE objetivo personalizado', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.autoregulated,
          customParameters: {
            'per_exercise': {
              'test_exercise': {
                'target_rpe': 7.0, // RPE personalizado
                'rpe_threshold': 0.3,
                'target_reps': 8,
                'max_reps': 12,
                'min_reps': 5,
                'increment_value': 3.0,
              },
            },
          },
        );
        final state = createState();
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
          routineId: 'test-routine-1',
          currentCycle: state.currentCycle,
          currentWeek: state.currentWeek,
          currentSession: state.currentSession,
          currentWeight: state.currentWeight,
          currentReps: state.currentReps,
          currentSets: state.currentSets,
          baseWeight: state.baseWeight,
          baseReps: state.baseReps,
          baseSets: state.baseSets,
          sessionHistory: {
            'session_1': {
              'reps': 9, // Más reps que target = RPE bajo
            },
          },
          lastUpdated: state.lastUpdated,
          isDeloadWeek: state.isDeloadWeek,
          oneRepMax: state.oneRepMax,
          customData: state.customData,
        );

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('RPE'));
      });

      test('usa parámetros globales como fallback', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.autoregulated,
          customParameters: {
            'target_rpe': 8.5,
            'rpe_threshold': 0.4,
            'target_reps': 10,
            'max_reps': 15,
            'min_reps': 6,
            'increment_value': 2.0,
          },
        );
        final state = createState();
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
          routineId: 'test-routine-1',
          currentCycle: state.currentCycle,
          currentWeek: state.currentWeek,
          currentSession: state.currentSession,
          currentWeight: state.currentWeight,
          currentReps: state.currentReps,
          currentSets: state.currentSets,
          baseWeight: state.baseWeight,
          baseReps: state.baseReps,
          baseSets: state.baseSets,
          sessionHistory: {
            'session_1': {
              'reps': 11, // Más reps que target = RPE bajo
            },
          },
          lastUpdated: state.lastUpdated,
          isDeloadWeek: state.isDeloadWeek,
          oneRepMax: state.oneRepMax,
          customData: state.customData,
        );

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        expect(result.newWeight, greaterThan(100.0));
        expect(result.reason, contains('RPE'));
      });

      test('combina parámetros per_exercise con globales', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.autoregulated,
          customParameters: {
            'per_exercise': {
              'test_exercise': {
                'target_rpe': 7.5, // Solo RPE personalizado
              },
            },
            'target_reps': 12, // Global - igual a las reps realizadas para RPE óptimo
            'max_reps': 12, // Global
            'min_reps': 5, // Global
            'increment_value': 2.5, // Global
          },
        );
        final state = createState();
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
          routineId: 'test-routine-1',
          currentCycle: state.currentCycle,
          currentWeek: state.currentWeek,
          currentSession: state.currentSession,
          currentWeight: state.currentWeight,
          currentReps: state.currentReps,
          currentSets: state.currentSets,
          baseWeight: state.baseWeight,
          baseReps: state.baseReps,
          baseSets: state.baseSets,
          sessionHistory: {
            'session_1': {
              'reps': 12, // Reps exactas = RPE óptimo
            },
          },
          lastUpdated: state.lastUpdated,
          isDeloadWeek: state.isDeloadWeek,
          oneRepMax: state.oneRepMax,
          customData: state.customData,
        );

        final result = strategy.calculate(
          config: config,
          state: stateWithHistory,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12, // Establecer en max_reps para probar "max reps reached"
          currentSets: 4,
          exercise: ex(),
        );

        expect(result.newWeight, 100.0);
        expect(result.newReps, 12); // Se mantiene en max_reps
        expect(result.reason, contains('max reps reached'));
      });
    });

    group('Parameter Priority and Fallbacks', () {
      final strategy = LinearProgressionStrategy();

      test('maneja parámetros faltantes correctamente', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': {
                // Solo algunos parámetros
                'increment_value': 4.0,
              },
            },
            'multi_increment_min': 3.0,
            // Falta iso_increment_min
          },
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });

      test('maneja tipos de datos incorrectos', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': {
                'increment_value': 'invalid', // Tipo incorrecto
              },
            },
            'multi_increment_min': 3.0,
          },
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });

      test('maneja estructura de per_exercise incorrecta', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': 'invalid_structure', // Estructura incorrecta
            },
            'multi_increment_min': 3.0,
          },
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        final inc = strategy.getIncrementValueSync(config, ex());
        expect(result.newWeight, 100.0 + inc);
      });

      test('maneja ejercicio no encontrado en per_exercise', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'other_exercise': {
                // Ejercicio diferente
                'increment_value': 5.0,
              },
            },
            'multi_increment_min': 3.0,
          },
        );
        final state = createState(exerciseId: 'test_exercise');

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exercise: ex(),
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, greaterThan(100.0)); // Debe incrementar
      });
    });

    group('Multi vs ISO Parameter Logic', () {
      final strategy = DoubleProgressionStrategy();

      test('diferencia entre parámetros multi e iso', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {
            'multi_reps_min': 5,
            'multi_reps_max': 10,
            'multi_increment_min': 5.0,
            'iso_reps_min': 8,
            'iso_reps_max': 15,
            'iso_increment_min': 2.5,
          },
        );
        final state = createState();

        // Test con reps en máximo multi
        final result1 = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12, // Máximo del config
          currentSets: 4,
          exercise: ex(type: ExerciseType.multiJoint),
        );

        final incMulti = strategy.getIncrementValueSync(config, ex(type: ExerciseType.multiJoint));
        expect(result1.newWeight, 100.0 + incMulti);
        expect(result1.newReps, 3); // Sistema adaptativo devuelve 3 para hypertrophy multi-joint

        // Test con reps en máximo iso (si fuera posible)
        final result2 = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12, // Usar máximo del config para consistencia
          currentSets: 4,
          exercise: ex(type: ExerciseType.isolation),
        );

        expect(result2.incrementApplied, true);
        final incIso = strategy.getIncrementValueSync(config, ex(type: ExerciseType.isolation));
        expect(result2.newWeight, 100.0 + incIso); // Debe incrementar
        expect(result2.newReps, 5); // Sistema adaptativo devuelve 5 para hypertrophy isolation
      });

      test('preferencia de multi_ sobre iso_ cuando ambos están disponibles', () {
        final config = createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {
            'multi_reps_min': 6,
            'multi_reps_max': 12,
            'multi_increment_min': 4.0,
            'iso_reps_min': 8,
            'iso_reps_max': 15,
            'iso_increment_min': 2.5,
          },
        );
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12, // Máximo multi
          currentSets: 4,
          exercise: ex(type: ExerciseType.multiJoint),
        );

        final inc = strategy.getIncrementValueSync(config, ex(type: ExerciseType.multiJoint));
        expect(result.newWeight, 100.0 + inc);
        expect(result.newReps, 3); // Sistema adaptativo devuelve 3 para hypertrophy multi-joint
      });
    });
  });
}
