import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/models/progression_calculation_result.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';

import '../helpers/exercise_mock_factory.dart';

void main() {
  group('DoubleFactorProgressionStrategy - Tests con Presets', () {
    late DoubleFactorProgressionStrategy strategy;
    late Exercise exercise;

    setUp(() {
      strategy = DoubleFactorProgressionStrategy();
      exercise = ExerciseMockFactory.createExercise();
    });

    /// Helper para crear estado de progresión
    ProgressionState createState({
      required int currentInCycle,
      required double baseWeight,
      required int baseReps,
      int? baseSets,
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
        currentSets: baseSets ?? 3,
        baseWeight: baseWeight,
        baseReps: baseReps,
        baseSets: baseSets ?? 3,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );
    }

    group('Preset de Hipertrofia', () {
      test('usa modo both y progresa peso y reps simultáneamente', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorHypertrophyPreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 80.0,
          baseReps: 8,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 8,
          currentSets: 3,
          exercise: exercise,
        );

        // Verificar que usa modo both
        expect(result.reason, contains('Double factor (both)'));
        expect(result.reason, contains('increasing weight'));
        expect(result.reason, contains('and reps'));

        // Verificar que incrementa peso y reps
        expect(result.newWeight, greaterThan(80.0));
        expect(result.newReps, greaterThan(8));
      });

      test('respeta rangos de reps del preset (8-12)', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorHypertrophyPreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 80.0,
          baseReps: 8,
        );

        // Simular progresión hasta alcanzar el máximo de reps
        double currentWeight = 80.0;
        int currentReps = 8;

        for (int week = 1; week <= 5; week++) {
          final weekState = createState(
            currentInCycle: week,
            baseWeight: 80.0,
            baseReps: 8,
          );

          final result = strategy.calculate(
            config: config,
            state: weekState,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Verificar que las reps están dentro del rango
          expect(currentReps, greaterThanOrEqualTo(8));
          expect(currentReps, lessThanOrEqualTo(12));
        }
      });

      test('aplica deload en la semana 6', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorHypertrophyPreset();
        final state = createState(
          currentInCycle: 6, // Semana de deload
          baseWeight: 80.0,
          baseReps: 8,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 90.0, // Peso actual mayor que base
          currentReps: 10, // Reps actuales mayores que base
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.isDeload, true);
        expect(result.shouldResetCycle, true);
        expect(result.reason, contains('Deload session'));
        expect(result.reason, contains('week 6'));
      });
    });

    group('Preset de Fuerza', () {
      test('usa modo alternate y alterna entre peso y reps', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorStrengthPreset();
        final state = createState(
          currentInCycle: 1, // Semana impar
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 80.0,
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        // Verificar que usa modo alternate
        expect(result.reason, contains('Double factor (alternate)'));
        expect(result.reason, contains('increasing weight'));
        expect(result.newReps, 6); // Mantiene reps en semana impar
      });

      test('alterna correctamente en semanas pares', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorStrengthPreset();
        final state = createState(
          currentInCycle: 2, // Semana par
          baseWeight: 80.0,
          baseReps: 6,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 82.5, // Peso de la semana anterior
          currentReps: 6,
          currentSets: 3,
          exercise: exercise,
        );

        expect(result.reason, contains('Double factor (alternate)'));
        expect(result.reason, contains('increasing reps'));
        expect(result.newWeight, 82.5); // Mantiene peso en semana par
        expect(
          result.newReps,
          6,
        ); // Incrementa reps pero se mantiene en el máximo del rango (3-6)
      });

      test('respeta rangos de reps del preset (3-6)', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorStrengthPreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 80.0,
          baseReps: 3,
        );

        // Simular progresión
        double currentWeight = 80.0;
        int currentReps = 3;

        for (int week = 1; week <= 4; week++) {
          final weekState = createState(
            currentInCycle: week,
            baseWeight: 80.0,
            baseReps: 3,
          );

          final result = strategy.calculate(
            config: config,
            state: weekState,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Verificar que las reps están dentro del rango
          expect(currentReps, greaterThanOrEqualTo(3));
          expect(currentReps, lessThanOrEqualTo(6));
        }
      });
    });

    group('Preset de Resistencia', () {
      test('usa modo alternate para progresión controlada', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorEndurancePreset();
        final state = createState(
          currentInCycle: 1, // Semana impar
          baseWeight: 60.0,
          baseReps: 12,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 60.0,
          currentReps: 12,
          currentSets: 3,
          exercise: exercise,
        );

        // Verificar que usa modo alternate
        expect(result.reason, contains('Double factor (alternate)'));
        expect(result.reason, contains('increasing weight'));
        expect(result.newReps, 12); // Mantiene reps en semana impar
      });

      test('respeta rangos de reps del preset (12-20)', () {
        final config =
            PresetProgressionConfigs.createDoubleFactorEndurancePreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 60.0,
          baseReps: 12,
        );

        // Simular progresión
        double currentWeight = 60.0;
        int currentReps = 12;

        for (int week = 1; week <= 4; week++) {
          final weekState = createState(
            currentInCycle: week,
            baseWeight: 60.0,
            baseReps: 12,
          );

          final result = strategy.calculate(
            config: config,
            state: weekState,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 3,
            exercise: exercise,
          );

          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Verificar que las reps están dentro del rango
          expect(currentReps, greaterThanOrEqualTo(12));
          expect(currentReps, lessThanOrEqualTo(20));
        }
      });
    });

    group('Preset de Potencia', () {
      test('usa modo composite para priorizar peso', () {
        final config = PresetProgressionConfigs.createDoubleFactorPowerPreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 100.0,
          baseReps: 1,
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 1,
          currentSets: 5,
          exercise: exercise,
        );

        // Verificar que usa modo composite
        expect(result.reason, contains('Double factor (composite)'));
        expect(result.reason, contains('increasing weight'));
        expect(result.reason, contains('and reps'));

        // Verificar que incrementa peso y reps
        expect(result.newWeight, greaterThan(100.0));
        expect(result.newReps, greaterThan(1));
      });

      test('respeta rangos de reps del preset (1-5)', () {
        final config = PresetProgressionConfigs.createDoubleFactorPowerPreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 100.0,
          baseReps: 1,
        );

        // Simular progresión
        double currentWeight = 100.0;
        int currentReps = 1;

        for (int week = 1; week <= 4; week++) {
          final weekState = createState(
            currentInCycle: week,
            baseWeight: 100.0,
            baseReps: 1,
          );

          final result = strategy.calculate(
            config: config,
            state: weekState,
            routineId: 'test-routine',
            currentWeight: currentWeight,
            currentReps: currentReps,
            currentSets: 5,
            exercise: exercise,
          );

          currentWeight = result.newWeight;
          currentReps = result.newReps;

          // Verificar que las reps están dentro del rango
          expect(currentReps, greaterThanOrEqualTo(1));
          expect(currentReps, lessThanOrEqualTo(5));
        }
      });

      test('usa 5 series como especifica el preset', () {
        final config = PresetProgressionConfigs.createDoubleFactorPowerPreset();
        final state = createState(
          currentInCycle: 1,
          baseWeight: 100.0,
          baseReps: 1,
          baseSets: 5, // Usar las series base del preset de potencia
        );

        final result = strategy.calculate(
          config: config,
          state: state,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 1,
          currentSets: 5,
          exercise: exercise,
        );

        expect(result.newSets, 5); // Usa las series base del preset (5)
      });
    });

    group('Comparación entre Presets', () {
      test('compara velocidad de progresión entre presets', () {
        final presets = [
          (
            'hypertrophy',
            PresetProgressionConfigs.createDoubleFactorHypertrophyPreset(),
          ),
          (
            'strength',
            PresetProgressionConfigs.createDoubleFactorStrengthPreset(),
          ),
          (
            'endurance',
            PresetProgressionConfigs.createDoubleFactorEndurancePreset(),
          ),
          ('power', PresetProgressionConfigs.createDoubleFactorPowerPreset()),
        ];

        final results = <String, ProgressionCalculationResult>{};

        for (final (name, config) in presets) {
          final state = createState(
            currentInCycle: 1,
            baseWeight: 80.0,
            baseReps: config.minReps,
          );

          final result = strategy.calculate(
            config: config,
            state: state,
            routineId: 'test-routine',
            currentWeight: 80.0,
            currentReps: config.minReps,
            currentSets: config.baseSets,
            exercise: exercise,
          );

          results[name] = result;
        }

        // Verificar que cada preset usa el modo correcto
        expect(
          results['hypertrophy']!.reason,
          contains('Double factor (both)'),
        );
        expect(
          results['strength']!.reason,
          contains('Double factor (alternate)'),
        );
        expect(
          results['endurance']!.reason,
          contains('Double factor (alternate)'),
        );
        expect(results['power']!.reason, contains('Double factor (composite)'));

        // Verificar que todos incrementan peso
        for (final result in results.values) {
          expect(result.newWeight, greaterThan(80.0));
          expect(result.incrementApplied, true);
        }
      });

      test('verifica que los presets tienen configuraciones apropiadas', () {
        final hypertrophyConfig =
            PresetProgressionConfigs.createDoubleFactorHypertrophyPreset();
        final strengthConfig =
            PresetProgressionConfigs.createDoubleFactorStrengthPreset();
        final enduranceConfig =
            PresetProgressionConfigs.createDoubleFactorEndurancePreset();
        final powerConfig =
            PresetProgressionConfigs.createDoubleFactorPowerPreset();

        // Verificar modos
        expect(
          hypertrophyConfig.customParameters['double_factor_mode'],
          'both',
        );
        expect(
          strengthConfig.customParameters['double_factor_mode'],
          'alternate',
        );
        expect(
          enduranceConfig.customParameters['double_factor_mode'],
          'alternate',
        );
        expect(powerConfig.customParameters['double_factor_mode'], 'composite');

        // Verificar rangos de reps apropiados para cada objetivo
        expect(hypertrophyConfig.minReps, 8);
        expect(hypertrophyConfig.maxReps, 12);
        expect(strengthConfig.minReps, 3);
        expect(strengthConfig.maxReps, 6);
        expect(enduranceConfig.minReps, 12);
        expect(enduranceConfig.maxReps, 20);
        expect(powerConfig.minReps, 1);
        expect(powerConfig.maxReps, 5);

        // Verificar series apropiadas
        expect(hypertrophyConfig.baseSets, 3);
        expect(strengthConfig.baseSets, 4);
        expect(enduranceConfig.baseSets, 3);
        expect(powerConfig.baseSets, 5); // Más series para potencia
      });
    });
  });
}
