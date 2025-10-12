import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/default_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/static_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

void main() {
  group('Comprehensive Strategy Tests', () {
    // Helper para crear configuraciones de prueba
    ProgressionConfig createConfig({
      required ProgressionType type,
      ProgressionUnit unit = ProgressionUnit.session,
      double incrementValue = 2.5,
      int incrementFrequency = 1,
      int cycleLength = 4,
      int deloadWeek = 0,
      double deloadPercentage = 0.9,
      Map<String, dynamic> customParameters = const {},
    }) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'test_config',
        isGlobal: true,
        type: type,
        unit: unit,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: incrementValue,
        incrementFrequency: incrementFrequency,
        cycleLength: cycleLength,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: deloadWeek,
        deloadPercentage: deloadPercentage,
        customParameters: customParameters,
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    // Helper para crear estados de progresión
    ProgressionState createState({
      int currentSession = 1,
      int currentWeek = 1,
      double currentWeight = 100.0,
      int currentReps = 10,
      int currentSets = 4,
      double baseWeight = 100.0,
      int baseReps = 10,
      int baseSets = 4,
      Map<String, dynamic> customData = const {},
    }) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'test_state',
        progressionConfigId: 'test_config',
        exerciseId: 'test_exercise',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: currentWeek,
        currentSession: currentSession,
        currentWeight: currentWeight,
        currentReps: currentReps,
        currentSets: currentSets,
        baseWeight: baseWeight,
        baseReps: baseReps,
        baseSets: baseSets,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: customData,
      );
    }

    group('LinearProgressionStrategy', () {
      final strategy = LinearProgressionStrategy();

      test('incrementa peso cuando coincide la frecuencia', () {
        final config = createConfig(type: ProgressionType.linear, unit: ProgressionUnit.session, incrementFrequency: 1);
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 102.5);
        expect(result.newReps, 10);
        expect(result.newSets, 3); // baseSets del config
        expect(result.reason, contains('Linear progression: weight +2.5kg'));
      });

      test('no incrementa cuando no coincide la frecuencia', () {
        final config = createConfig(type: ProgressionType.linear, unit: ProgressionUnit.session, incrementFrequency: 2);
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, false);
        expect(result.newWeight, 100.0);
        expect(result.reason, contains('no increment'));
      });

      test('aplica deload correctamente manteniendo progreso', () {
        final config = createConfig(
          type: ProgressionType.linear,
          unit: ProgressionUnit.session,
          deloadWeek: 1,
          deloadPercentage: 0.9,
        );
        final state = createState(
          currentSession: 1,
          currentWeight: 120.0, // 20kg por encima del base
          baseWeight: 100.0,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 118.0); // 100 + (20 * 0.9)
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
        expect(result.reason, contains('deload'));
      });

      test('usa parámetros personalizados por ejercicio', () {
        final config = createConfig(
          type: ProgressionType.linear,
          customParameters: {
            'per_exercise': {
              'test_exercise': {'increment_value': 5.0},
            },
          },
        );
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 105.0); // Usa incremento personalizado
        expect(result.reason, contains('+5.0kg'));
      });
    });

    group('DoubleProgressionStrategy', () {
      final strategy = DoubleProgressionStrategy();

      test('incrementa reps hasta máximo', () {
        final config = createConfig(type: ProgressionType.double, customParameters: {'min_reps': 8, 'max_reps': 12});
        final state = createState(currentReps: 10);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newReps, 11);
        expect(result.newWeight, 100.0);
        expect(result.reason, contains('increasing reps'));
      });

      test('incrementa peso y resetea reps cuando alcanza máximo', () {
        final config = createConfig(type: ProgressionType.double, customParameters: {'min_reps': 8, 'max_reps': 12});
        final state = createState(currentReps: 12);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 12,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 102.5);
        expect(result.newReps, 8);
        expect(result.reason, contains('increasing weight'));
        expect(result.reason, contains('resetting reps'));
      });

      test('deload correcto manteniendo progreso', () {
        final config = createConfig(type: ProgressionType.double, deloadWeek: 1, deloadPercentage: 0.9);
        final state = createState(currentSession: 1, currentWeight: 120.0, baseWeight: 100.0);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 118.0); // 100 + (20 * 0.9)
        expect(result.newSets, 2); // baseSets 3 * 0.7 = 2.1 -> 2
        expect(result.reason, contains('deload'));
      });

      test('usa parámetros multi_ vs iso_ según tipo de ejercicio', () {
        final config = createConfig(
          type: ProgressionType.double,
          customParameters: {
            'multi_reps_min': 5,
            'multi_reps_max': 10,
            'iso_reps_min': 8,
            'iso_reps_max': 15,
            'multi_increment_min': 5.0,
            'iso_increment_min': 2.5,
          },
        );
        final state = createState(currentReps: 10);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
          exerciseType: ExerciseType.multiJoint,
        );

        expect(result.newWeight, 105.0); // Usa multi_increment_min
        expect(result.newReps, 5); // Usa multi_reps_min
      });
    });

    group('UndulatingProgressionStrategy', () {
      final strategy = UndulatingProgressionStrategy();

      test('día pesado: más peso, menos reps', () {
        final config = createConfig(type: ProgressionType.undulating, unit: ProgressionUnit.session);
        final state = createState(currentSession: 1); // Impar = día pesado

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 102.5);
        expect(result.newReps, 9); // 10 * 0.85 round
        expect(result.reason, contains('heavy day'));
      });

      test('día ligero: menos peso, más reps', () {
        final config = createConfig(type: ProgressionType.undulating, unit: ProgressionUnit.session);
        final state = createState(currentSession: 2); // Par = día ligero

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 97.5); // 100 - 2.5
        expect(result.newReps, 12); // 10 * 1.15 round
        expect(result.reason, contains('light day'));
      });

      test('deload correcto', () {
        final config = createConfig(type: ProgressionType.undulating, deloadWeek: 1, deloadPercentage: 0.9);
        final state = createState(currentSession: 1, currentWeight: 120.0, baseWeight: 100.0);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 118.0);
        expect(result.newSets, 2); // baseSets 3 * 0.7 = 2.1 -> 2
        expect(result.reason, contains('deload'));
      });
    });

    group('SteppedProgressionStrategy', () {
      final strategy = SteppedProgressionStrategy();

      test('acumula incrementos durante semanas específicas', () {
        final config = createConfig(
          type: ProgressionType.stepped,
          unit: ProgressionUnit.week,
          customParameters: {'accumulation_weeks': 3},
        );
        final state = createState(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 105.0); // baseWeight + (2.5 * 2)
        expect(result.reason, contains('accumulation phase'));
      });

      test('deload correcto', () {
        final config = createConfig(type: ProgressionType.stepped, deloadWeek: 1, deloadPercentage: 0.9);
        final state = createState(currentSession: 1, currentWeight: 120.0, baseWeight: 100.0);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 118.0);
        expect(result.newSets, 2); // 3 * 0.7 round (baseSets del config)
        expect(result.reason, contains('deload'));
      });
    });

    group('WaveProgressionStrategy', () {
      final strategy = WaveProgressionStrategy();

      test('semana 1: alta intensidad', () {
        final config = createConfig(type: ProgressionType.wave, unit: ProgressionUnit.week);
        final state = createState(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 102.5);
        expect(result.newReps, 9); // 10 * 0.85 round
        expect(result.reason, contains('high intensity'));
      });

      test('semana 2: alto volumen', () {
        final config = createConfig(type: ProgressionType.wave, unit: ProgressionUnit.week);
        final state = createState(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 99.25); // 100 - (2.5 * 0.3)
        expect(result.newReps, 12); // 10 * 1.2 round
        expect(result.newSets, 5); // 4 + 1
        expect(result.reason, contains('high volume'));
      });

      test('semana 3: deload', () {
        final config = createConfig(
          type: ProgressionType.wave,
          unit: ProgressionUnit.week,
          cycleLength: 3,
          deloadWeek: 3,
          deloadPercentage: 0.9,
        );
        final state = createState(currentWeek: 3, currentWeight: 120.0, baseWeight: 100.0);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 90.0);
        expect(result.newSets, 4); // 4 * 0.9 = 3.6 rounded to 4
        expect(result.reason, contains('deload'));
      });
    });

    group('StaticProgressionStrategy', () {
      final strategy = StaticProgressionStrategy();

      test('mantiene valores constantes', () {
        final config = createConfig(type: ProgressionType.static);
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, false);
        expect(result.newWeight, 100.0);
        expect(result.newReps, 10);
        expect(result.newSets, 4);
        expect(result.reason, contains('maintaining current values'));
      });
    });

    group('ReverseProgressionStrategy', () {
      final strategy = ReverseProgressionStrategy();

      test('reduce peso y aumenta reps', () {
        final config = createConfig(type: ProgressionType.reverse, customParameters: {'max_reps': 15});
        final state = createState(currentReps: 10);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 97.5); // 100 - 2.5
        expect(result.newReps, 11);
        expect(result.reason, contains('decreasing weight'));
        expect(result.reason, contains('increasing reps'));
      });

      test('mantiene reps en máximo y sigue reduciendo peso', () {
        final config = createConfig(type: ProgressionType.reverse, customParameters: {'max_reps': 15});
        final state = createState(currentReps: 15);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 15,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 97.5);
        expect(result.newReps, 15); // Mantiene en máximo
        expect(result.reason, contains('maintaining max reps'));
      });

      test('deload correcto', () {
        final config = createConfig(type: ProgressionType.reverse, deloadWeek: 1, deloadPercentage: 0.9);
        final state = createState(currentSession: 1, currentWeight: 120.0, baseWeight: 100.0);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 118.0);
        expect(result.newSets, 3);
        expect(result.reason, contains('deload'));
      });
    });

    group('AutoregulatedProgressionStrategy', () {
      final strategy = AutoregulatedProgressionStrategy();

      test('incrementa peso cuando RPE es bajo', () {
        final config = createConfig(
          type: ProgressionType.autoregulated,
          customParameters: {'target_rpe': 8.0, 'rpe_threshold': 0.5, 'target_reps': 10, 'max_reps': 12, 'min_reps': 5},
        );
        final state = createState(currentSession: 1);
        // Simular sessionHistory en customData para el test
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
          routineId: state.routineId,
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
              'reps': 12, // Más reps que target = RPE bajo
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
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 102.5);
        expect(result.reason, contains('RPE low'));
      });

      test('reduce peso cuando RPE es alto', () {
        final config = createConfig(
          type: ProgressionType.autoregulated,
          customParameters: {'target_rpe': 8.0, 'rpe_threshold': 0.5, 'target_reps': 10, 'max_reps': 12, 'min_reps': 5},
        );
        final state = createState(currentSession: 1);
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
          routineId: state.routineId,
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
              'reps': 8, // Menos reps que target = RPE alto
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
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 98.75); // 100 - (2.5 * 0.5)
        expect(result.reason, contains('RPE high'));
      });

      test('incrementa reps cuando RPE es óptimo', () {
        final config = createConfig(
          type: ProgressionType.autoregulated,
          customParameters: {'target_rpe': 8.0, 'rpe_threshold': 0.5, 'target_reps': 10, 'max_reps': 12, 'min_reps': 5},
        );
        final state = createState(currentSession: 1);
        final stateWithHistory = ProgressionState(
          id: state.id,
          progressionConfigId: state.progressionConfigId,
          exerciseId: state.exerciseId,
          routineId: state.routineId,
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
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 100.0);
        expect(result.newReps, 11);
        expect(result.reason, contains('increasing reps'));
      });

      test('deload correcto', () {
        final config = createConfig(type: ProgressionType.autoregulated, deloadWeek: 1, deloadPercentage: 0.9);
        final state = createState(currentSession: 1, currentWeight: 120.0, baseWeight: 100.0);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 118.0);
        expect(result.newSets, 3);
        expect(result.reason, contains('deload'));
      });
    });

    group('DefaultProgressionStrategy', () {
      final strategy = DefaultProgressionStrategy();

      test('no aplica cambios', () {
        final config = createConfig(type: ProgressionType.linear);
        final state = createState();

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, false);
        expect(result.newWeight, 100.0);
        expect(result.newReps, 10);
        expect(result.newSets, 4);
        expect(result.reason, contains('Default progression: no changes'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('maneja pesos negativos correctamente', () {
        final strategy = ReverseProgressionStrategy();
        final config = createConfig(type: ProgressionType.reverse);
        final state = createState(currentWeight: 2.0); // Peso muy bajo

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 2.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.newWeight, 0.0); // Clamp a 0
        expect(result.incrementApplied, true);
      });

      test('maneja reps mínimas correctamente', () {
        final strategy = UndulatingProgressionStrategy();
        final config = createConfig(type: ProgressionType.undulating);
        final state = createState(currentReps: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 1,
          currentSets: 4,
        );

        expect(result.newReps, 1); // Clamp a mínimo
        expect(result.incrementApplied, true);
      });

      test('maneja configuraciones sin deload', () {
        final strategy = LinearProgressionStrategy();
        final config = createConfig(
          type: ProgressionType.linear,
          deloadWeek: 0, // Sin deload
        );
        final state = createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 102.5);
        expect(result.reason, isNot(contains('deload')));
      });
    });
  });
}
