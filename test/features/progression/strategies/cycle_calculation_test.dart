import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  group('Cycle Calculation Tests', () {
    // Helper para crear configuraciones
    ProgressionConfig _createConfig({required ProgressionUnit unit, int cycleLength = 4, int deloadWeek = 0}) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cycle_test_config',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: unit,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: cycleLength,
        deloadWeek: deloadWeek,
        deloadPercentage: 0.9,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    // Helper para crear estados
    ProgressionState _createState({int currentSession = 1, int currentWeek = 1}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'cycle_test_state',
        progressionConfigId: 'cycle_test_config',
        exerciseId: 'test_exercise',
        currentCycle: 1,
        currentWeek: currentWeek,
        currentSession: currentSession,
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

    group('Session-based Cycle Calculation', () {
      final strategy = LinearProgressionStrategy();

      test('sesión 1 en ciclo de 4 sesiones', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final state = _createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 4'));
      });

      test('sesión 2 en ciclo de 4 sesiones', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final state = _createState(currentSession: 2);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 2 of 4'));
      });

      test('sesión 4 en ciclo de 4 sesiones', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final state = _createState(currentSession: 4);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 4 of 4'));
      });

      test('sesión 5 reinicia ciclo (sesión 1 del siguiente ciclo)', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final state = _createState(currentSession: 5);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 4')); // Reinicia
      });

      test('sesión 8 en ciclo de 4 sesiones (sesión 4 del segundo ciclo)', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final state = _createState(currentSession: 8);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 4 of 4'));
      });

      test('deload en sesión 3 de ciclo de 4', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4, deloadWeek: 3);
        final state = _createState(currentSession: 3);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('deload session'));
        expect(result.reason, contains('week 3 of 4'));
      });
    });

    group('Week-based Cycle Calculation', () {
      final strategy = LinearProgressionStrategy();

      test('semana 1 en ciclo de 4 semanas', () {
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 4);
        final state = _createState(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 4'));
      });

      test('semana 4 en ciclo de 4 semanas', () {
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 4);
        final state = _createState(currentWeek: 4);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 4 of 4'));
      });

      test('semana 5 reinicia ciclo (semana 1 del siguiente ciclo)', () {
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 4);
        final state = _createState(currentWeek: 5);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 4')); // Reinicia
      });

      test('deload en semana 3 de ciclo de 4', () {
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 4, deloadWeek: 3);
        final state = _createState(currentWeek: 3);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('deload week'));
        expect(result.reason, contains('week 3 of 4'));
      });
    });

    group('WaveProgressionStrategy Cycle Logic', () {
      final strategy = WaveProgressionStrategy();

      test('semana 1: alta intensidad', () {
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 3);
        final state = _createState(currentWeek: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
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
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 3);
        final state = _createState(currentWeek: 2);

        final result = strategy.calculate(
          config: config,
          state: state,
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
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 3, deloadWeek: 3);
        final state = _createState(currentWeek: 3);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 120.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.newWeight, 90.0);
        expect(result.newSets, 3);
        expect(result.reason, contains('deload week'));
      });

      test('semana 4 reinicia ciclo (semana 1 del siguiente ciclo)', () {
        final config = _createConfig(unit: ProgressionUnit.week, cycleLength: 3);
        final state = _createState(currentWeek: 4);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('high intensity')); // Reinicia
      });
    });

    group('Cycle Edge Cases', () {
      final strategy = LinearProgressionStrategy();

      test('ciclo de 1 sesión', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 1);
        final state = _createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 1'));
      });

      test('ciclo de 1 sesión - sesión 2 reinicia', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 1);
        final state = _createState(currentSession: 2);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 1 of 1')); // Reinicia
      });

      test('ciclo largo (10 sesiones)', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 10);
        final state = _createState(currentSession: 7);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, contains('week 7 of 10'));
      });

      test('deload en sesión 0 (sin deload)', () {
        final config = _createConfig(
          unit: ProgressionUnit.session,
          cycleLength: 4,
          deloadWeek: 0, // Sin deload
        );
        final state = _createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, isNot(contains('deload')));
      });

      test('deload en sesión mayor al ciclo', () {
        final config = _createConfig(
          unit: ProgressionUnit.session,
          cycleLength: 4,
          deloadWeek: 5, // Deload fuera del ciclo
        );
        final state = _createState(currentSession: 1);

        final result = strategy.calculate(
          config: config,
          state: state,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );

        expect(result.incrementApplied, true);
        expect(result.reason, isNot(contains('deload')));
      });
    });

    group('Frequency and Cycle Interaction', () {
      final strategy = LinearProgressionStrategy();

      test('frecuencia 2 en ciclo de 4 sesiones', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        // Modificar frecuencia después de crear
        final modifiedConfig = ProgressionConfig(
          id: config.id,
          isGlobal: config.isGlobal,
          type: config.type,
          unit: config.unit,
          primaryTarget: config.primaryTarget,
          secondaryTarget: config.secondaryTarget,
          incrementValue: config.incrementValue,
          incrementFrequency: 2, // Frecuencia 2
          cycleLength: config.cycleLength,
          deloadWeek: config.deloadWeek,
          deloadPercentage: config.deloadPercentage,
          customParameters: config.customParameters,
          startDate: config.startDate,
          endDate: config.endDate,
          isActive: config.isActive,
          createdAt: config.createdAt,
          updatedAt: config.updatedAt,
        );

        // Sesión 1: no incrementa (1 % 2 != 0)
        final state1 = _createState(currentSession: 1);
        final result1 = strategy.calculate(
          config: modifiedConfig,
          state: state1,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );
        expect(result1.incrementApplied, false);

        // Sesión 2: incrementa (2 % 2 == 0)
        final state2 = _createState(currentSession: 2);
        final result2 = strategy.calculate(
          config: modifiedConfig,
          state: state2,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );
        expect(result2.incrementApplied, true);
        expect(result2.reason, contains('week 2 of 4'));

        // Sesión 4: incrementa (4 % 2 == 0)
        final state4 = _createState(currentSession: 4);
        final result4 = strategy.calculate(
          config: modifiedConfig,
          state: state4,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );
        expect(result4.incrementApplied, true);
        expect(result4.reason, contains('week 4 of 4'));
      });

      test('frecuencia 3 en ciclo de 4 sesiones', () {
        final config = _createConfig(unit: ProgressionUnit.session, cycleLength: 4);
        final modifiedConfig = ProgressionConfig(
          id: config.id,
          isGlobal: config.isGlobal,
          type: config.type,
          unit: config.unit,
          primaryTarget: config.primaryTarget,
          secondaryTarget: config.secondaryTarget,
          incrementValue: config.incrementValue,
          incrementFrequency: 3, // Frecuencia 3
          cycleLength: config.cycleLength,
          deloadWeek: config.deloadWeek,
          deloadPercentage: config.deloadPercentage,
          customParameters: config.customParameters,
          startDate: config.startDate,
          endDate: config.endDate,
          isActive: config.isActive,
          createdAt: config.createdAt,
          updatedAt: config.updatedAt,
        );

        // Solo sesión 3 incrementa (3 % 3 == 0)
        final state3 = _createState(currentSession: 3);
        final result3 = strategy.calculate(
          config: modifiedConfig,
          state: state3,
          currentWeight: 100.0,
          currentReps: 10,
          currentSets: 4,
        );
        expect(result3.incrementApplied, true);
        expect(result3.reason, contains('week 3 of 4'));
      });
    });
  });
}
