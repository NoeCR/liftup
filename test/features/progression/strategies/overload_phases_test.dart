import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';

void main() {
  group('OverloadProgressionStrategy - Fases Automáticas', () {
    late OverloadProgressionStrategy strategy;

    setUp(() {
      strategy = OverloadProgressionStrategy();
    });

    ProgressionConfig config({
      String overloadType = 'phases',
      double overloadRate = 0.1,
      int phaseDurationWeeks = 4,
      double accumulationRate = 0.15,
      double intensificationRate = 0.1,
      double peakingRate = 0.05,
      int cycleLength = 12,
      int deloadWeek = 12,
      double deloadPercentage = 0.8,
    }) {
      return ProgressionConfig(
        id: 'test-config',
        isGlobal: true,
        type: ProgressionType.overload,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        incrementValue: 0.0,
        incrementFrequency: 1,
        cycleLength: cycleLength,
        deloadWeek: deloadWeek,
        deloadPercentage: deloadPercentage,
        customParameters: {
          'overload_type': overloadType,
          'overload_rate': overloadRate,
          'phase_duration_weeks': phaseDurationWeeks,
          'accumulation_rate': accumulationRate,
          'intensification_rate': intensificationRate,
          'peaking_rate': peakingRate,
        },
        startDate: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    ProgressionState state({
      int currentWeek = 1,
      double baseWeight = 100.0,
      int baseSets = 4,
    }) {
      return ProgressionState(
        id: 'test-state',
        progressionConfigId: 'test-config',
        exerciseId: 'test-exercise',
        routineId: 'test-routine',
        currentCycle: 1,
        currentWeek: currentWeek,
        currentSession: 1,
        currentWeight: baseWeight,
        currentReps: 8,
        currentSets: baseSets,
        baseWeight: baseWeight,
        baseReps: 8,
        baseSets: baseSets,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );
    }

    group('Determinación de Fases', () {
      test('Semana 1-4: Fase de Acumulación', () {
        final cfg = config();
        final st = state(currentWeek: 1);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('accumulation phase'));
        expect(result.reason, contains('volume focus'));
        expect(result.newSets, greaterThan(st.baseSets)); // Incrementa volumen
        expect(result.newWeight, equals(100.0)); // Mantiene peso
      });

      test('Semana 5-8: Fase de Intensificación', () {
        final cfg = config();
        final st = state(currentWeek: 5);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('intensification phase'));
        expect(result.reason, contains('intensity focus'));
        expect(result.newWeight, greaterThan(100.0)); // Incrementa peso
        expect(result.newSets, equals(st.baseSets)); // Mantiene series
      });

      test('Semana 9-12: Fase de Peaking', () {
        final cfg = config();
        final st = state(currentWeek: 9);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('peaking phase'));
        expect(result.reason, contains('max intensity, reduced volume'));
        expect(result.newWeight, greaterThan(100.0)); // Incrementa peso
        expect(result.newSets, lessThan(st.baseSets)); // Reduce volumen
      });
    });

    group('Tipos de Sobrecarga', () {
      test('Sobrecarga de Volumen', () {
        final cfg = config(overloadType: 'volume', overloadRate: 0.1);
        final st = state();

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('increasing volume'));
        expect(result.newSets, equals(4 + (4 * 0.1).round())); // 4 → 4.4 → 4
        expect(result.newWeight, equals(100.0)); // Mantiene peso
      });

      test('Sobrecarga de Intensidad', () {
        final cfg = config(overloadType: 'intensity', overloadRate: 0.1);
        final st = state();

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('increasing intensity'));
        expect(result.newWeight, equals(110.0)); // 100 * 1.1
        expect(result.newSets, equals(4)); // Mantiene series
      });

      test('Sobrecarga por Fases (Automática)', () {
        final cfg = config(overloadType: 'phases');
        final st = state();

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('accumulation phase'));
        expect(result.reason, contains('volume focus'));
      });
    });

    group('Parámetros de Fases', () {
      test('Tasa de Acumulación Personalizada', () {
        final cfg = config(accumulationRate: 0.2); // 20%
        final st = state();

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.newSets, equals(4 + (4 * 0.2).round())); // 4 → 4.8 → 4
      });

      test('Tasa de Intensificación Personalizada', () {
        final cfg = config(intensificationRate: 0.15); // 15%
        final st = state(currentWeek: 5);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.newWeight, equals(115.0)); // 100 * 1.15
      });

      test('Tasa de Peaking Personalizada', () {
        final cfg = config(peakingRate: 0.08); // 8%
        final st = state(currentWeek: 9);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.newWeight, equals(108.0)); // 100 * 1.08
        expect(result.newSets, equals(3)); // 4 * 0.8 = 3.2 → 3
      });
    });

    group('Duración de Fases', () {
      test('Fases de 3 semanas', () {
        final cfg = config(phaseDurationWeeks: 3, cycleLength: 9);
        final st = state(currentWeek: 4); // Debería estar en intensificación

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('intensification phase'));
        expect(
          result.reason,
          contains('week 1/3'),
        ); // Primera semana de intensificación
      });

      test('Fases de 6 semanas', () {
        final cfg = config(phaseDurationWeeks: 6, cycleLength: 18);
        final st = state(currentWeek: 7); // Debería estar en intensificación

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('intensification phase'));
        expect(
          result.reason,
          contains('week 1/6'),
        ); // Primera semana de intensificación
      });
    });

    group('Deloads', () {
      test('Deload en semana 12', () {
        final cfg = config(deloadWeek: 12);
        final st = state(currentWeek: 12);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.isDeload, isTrue);
        expect(result.reason, contains('deload'));
        expect(result.newSets, equals(3)); // 4 * 0.7 = 2.8 → 3
      });
    });

    group('Casos Edge', () {
      test('Semana 0 (antes del inicio)', () {
        final cfg = config();
        final st = state(currentWeek: 0);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(
          result.reason,
          contains('accumulation phase'),
        ); // Debería estar en acumulación
      });

      test('Semana muy alta (fuera del ciclo)', () {
        final cfg = config();
        final st = state(currentWeek: 20);

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(
          result.reason,
          contains('peaking phase'),
        ); // Debería estar en peaking
      });

      test('Parámetros faltantes usan valores por defecto', () {
        final cfg = ProgressionConfig(
          id: 'test-config',
          isGlobal: true,
          type: ProgressionType.overload,
          unit: ProgressionUnit.week,
          primaryTarget: ProgressionTarget.weight,
          incrementValue: 0.0,
          incrementFrequency: 1,
          cycleLength: 12,
          deloadWeek: 12,
          deloadPercentage: 0.8,
          customParameters: {
            'overload_type': 'phases',
            // Faltan otros parámetros
          },
          startDate: DateTime.now(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final st = state();

        final result = strategy.calculate(
          config: cfg,
          state: st,
          routineId: 'test-routine',
          currentWeight: 100.0,
          currentReps: 8,
          currentSets: 4,
        );

        expect(result.reason, contains('accumulation phase'));
        expect(
          result.newSets,
          equals(4 + (4 * 0.15).round()),
        ); // Usa valor por defecto 0.15
      });
    });
  });
}
