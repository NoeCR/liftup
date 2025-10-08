import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  group('Custom Parameters Tests', () {
    // Helper para crear configuraciones con parámetros personalizados
    ProgressionConfig _createConfigWithCustomParams({
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

    // Helper para crear estados
    ProgressionState _createState({String exerciseId = 'test_exercise'}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'custom_test_state',
        progressionConfigId: 'custom_test_config',
        exerciseId: exerciseId,
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

      test('usa incremento personalizado por ejercicio', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': {'increment_value': 5.0},
            },
          },
        );
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 105.0); // Usa incremento personalizado
        expect(result.reason, contains('+5.0kg'));
      });

      test('usa incremento multi_ como fallback', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {'multi_increment_min': 3.0, 'iso_increment_min': 1.5},
        );
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 102.5); // Usa incrementValue base (2.5)
        expect(result.reason, contains('+2.5kg'));
      });

      test('usa incremento iso_ como fallback', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {'iso_increment_min': 1.5},
        );
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 102.5); // Usa incrementValue base (2.5)
        expect(result.reason, contains('+2.5kg'));
      });

      test('fallback al valor base cuando no hay parámetros personalizados', () {
        final config = _createConfigWithCustomParams(type: ProgressionType.linear, customParameters: const {});
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 102.5); // Usa incrementValue base
        expect(result.reason, contains('+2.5kg'));
      });

      test('prioridad: per_exercise > multi_ > iso_ > base', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': {
                'increment_value': 10.0, // Mayor prioridad
              },
            },
            'multi_increment_min': 5.0,
            'iso_increment_min': 3.0,
          },
        );
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 110.0); // Usa per_exercise
        expect(result.reason, contains('+10.0kg'));
      });
    });

    group('DoubleProgressionStrategy Custom Parameters', () {
      final strategy = DoubleProgressionStrategy();

      test('usa min/max reps personalizados por ejercicio', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {
            'per_exercise': {
              'test_exercise': {'min_reps': 6, 'max_reps': 14, 'increment_value': 3.0},
            },
          },
        );
        final state = _createState();

        // Test incremento de reps
        final result1 = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result1.newReps, 11);
        expect(result1.newWeight, 100.0);

        // Test incremento de peso cuando alcanza máximo
        final result2 = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 14, // Máximo personalizado
          currentSets: 4,
        );

        expect(result2.newWeight, 103.0); // Usa incremento personalizado
        expect(result2.newReps, 6); // Usa min_reps personalizado
      });

      test('usa parámetros multi_ vs iso_ según contexto', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10, // Máximo multi
          currentSets: 4,
        );

        expect(result.newWeight, 105.0); // Usa multi_increment_min
        expect(result.newReps, 5); // Usa multi_reps_min
      });

      test('fallback a parámetros globales', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.double,
          customParameters: {'min_reps': 6, 'max_reps': 12, 'increment_value': 3.0},
        );
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 12,
          currentSets: 4,
        );

        expect(result.newWeight, 103.0); // Usa increment_value global
        expect(result.newReps, 6); // Usa min_reps global
      });
    });

    group('AutoregulatedProgressionStrategy Custom Parameters', () {
      final strategy = AutoregulatedProgressionStrategy();

      test('usa RPE objetivo personalizado', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
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
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('RPE'));
      });

      test('usa parámetros globales como fallback', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
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
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 102.0); // Usa increment_value global
        expect(result.reason, contains('RPE low'));
      });

      test('combina parámetros per_exercise con globales', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.autoregulated,
          customParameters: {
            'per_exercise': {
              'test_exercise': {
                'target_rpe': 7.5, // Solo RPE personalizado
              },
            },
            'target_reps': 10, // Global
            'max_reps': 12, // Global
            'min_reps': 5, // Global
            'increment_value': 2.5, // Global
          },
        );
        final state = _createState();
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
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
              'reps': 10, // Reps exactas = RPE óptimo
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
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 100.0);
        expect(result.newReps, 11); // Incrementa reps
        expect(result.reason, contains('increasing reps'));
      });
    });

    group('Parameter Priority and Fallbacks', () {
      final strategy = LinearProgressionStrategy();

      test('maneja parámetros faltantes correctamente', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 104.0); // Usa per_exercise
      });

      test('maneja tipos de datos incorrectos', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 102.5); // Fallback a incrementValue base
      });

      test('maneja estructura de per_exercise incorrecta', () {
        final config = _createConfigWithCustomParams(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': 'invalid_structure', // Estructura incorrecta
            },
            'multi_increment_min': 3.0,
          },
        );
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 102.5); // Fallback a incrementValue base
      });

      test('maneja ejercicio no encontrado en per_exercise', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState(exerciseId: 'test_exercise');

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, greaterThan(100.0)); // Debe incrementar
      });
    });

    group('Multi vs ISO Parameter Logic', () {
      final strategy = DoubleProgressionStrategy();

      test('diferencia entre parámetros multi e iso', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();

        // Test con reps en máximo multi
        final result1 = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10, // Máximo multi
          currentSets: 4,
        );

        expect(result1.newWeight, 105.0); // multi_increment_min
        expect(result1.newReps, 5); // multi_reps_min

        // Test con reps en máximo iso (si fuera posible)
        final result2 = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 15, // Máximo iso
          currentSets: 4,
        );

        expect(result2.incrementApplied, true);
        expect(result2.newWeight, greaterThan(100.0)); // Debe incrementar
        expect(result2.newReps, 5); // iso_reps_min
      });

      test('preferencia de multi_ sobre iso_ cuando ambos están disponibles', () {
        final config = _createConfigWithCustomParams(
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
        final state = _createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 12, // Máximo multi
          currentSets: 4,
        );

        expect(result.newWeight, 104.0); // Usa multi_increment_min
        expect(result.newReps, 6); // Usa multi_reps_min
      });
    });
  });
}
