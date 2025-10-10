import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('LinearProgressionStrategy', () {
    final strategy = LinearProgressionStrategy();

    ProgressionConfig config({
      ProgressionUnit unit = ProgressionUnit.session,
      double increment = 2.5,
      int freq = 1,
      int cycle = 4,
      int deloadWeek = 0,
      double deloadPct = 0.9,
    }) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: unit,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: increment,
        incrementFrequency: freq,
        cycleLength: cycle,
        deloadWeek: deloadWeek,
        deloadPercentage: deloadPct,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState state({int session = 1, int week = 1, double baseW = 100, int baseR = 10, int baseS = 4}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: week,
        currentSession: session,
        currentWeight: baseW,
        currentReps: baseR,
        currentSets: baseS,
        baseWeight: baseW,
        baseReps: baseR,
        baseSets: baseS,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    test('increments weight on frequency match', () {
      final cfg = config(freq: 1, unit: ProgressionUnit.session);
      final st = state(session: 1);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.incrementApplied, true);
      expect(res.newWeight, 102.5);
      expect(res.newReps, 10);
    });

    test('applies deload on deloadWeek', () {
      final cfg = config(unit: ProgressionUnit.session, deloadWeek: 1, deloadPct: 0.9);
      final st = state(session: 1);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 120,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.incrementApplied, true);
      // Deload: baseWeight + (increaseOverBase * deloadPercentage)
      // increaseOverBase = 120 - 100 = 20
      // deloadWeight = 100 + (20 * 0.9) = 118.0
      expect(res.newWeight, closeTo(118.0, 0.0001));
      expect(res.newSets, 3); // 4 * 0.7 round
    });

    test('restores sets to base after deload when increment applies', () {
      // freq=1 fuerza incremento; no es semana de deload
      final cfg = config(freq: 1, unit: ProgressionUnit.session, deloadWeek: 0);
      // Simulamos venir de deload: currentSets=3 pero baseSets=4
      final st = state(session: 1, baseS: 4);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 3, // heredado de deload anterior
      );
      expect(res.incrementApplied, true);
      expect(res.newSets, 4); // debe restaurar a baseSets
    });

    test('restores sets to base after deload when no increment applies', () {
      // freq=2 y session=1 -> no incremento; no es semana de deload
      final cfg = config(freq: 2, unit: ProgressionUnit.session, deloadWeek: 0);
      final st = state(session: 1, baseS: 4);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 3, // heredado de deload anterior
      );
      expect(res.incrementApplied, false);
      expect(res.newSets, 4); // debe restaurar a baseSets
    });

    test('no increment when frequency not matched', () {
      final cfg = config(freq: 2, unit: ProgressionUnit.session);
      final st = state(session: 1);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.incrementApplied, false);
      expect(res.newWeight, 100);
    });
  });
}
