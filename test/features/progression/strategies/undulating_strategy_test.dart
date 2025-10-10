import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/undulating_progression_strategy.dart';

void main() {
  group('UndulatingProgressionStrategy', () {
    final strategy = UndulatingProgressionStrategy();

    ProgressionConfig config() {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.undulating,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5,
        incrementFrequency: 2,
        cycleLength: 6,
        deloadWeek: 6,
        deloadPercentage: 0.85,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState state({int week = 1, double weight = 100, int reps = 10}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: week,
        currentSession: 1,
        currentWeight: weight,
        currentReps: reps,
        currentSets: 4,
        baseWeight: weight,
        baseReps: reps,
        baseSets: 4,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    test('week 1 heavy day', () {
      final cfg = config();
      final st = state(week: 1, weight: 100, reps: 10);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.incrementApplied, true);
      expect(res.newWeight, closeTo(102.5, 0.0001));
      expect(res.newReps, 9);
      // clamp mínimo
      expect(res.newReps, greaterThanOrEqualTo(6));
    });

    test('week 2 light day', () {
      final cfg = config();
      final st = state(week: 2, weight: 100, reps: 10);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.incrementApplied, true);
      expect(res.newWeight, closeTo(97.5, 0.0001));
      expect(res.newReps, 12);
      // clamp mínimo
      expect(res.newReps, greaterThanOrEqualTo(6));
    });
  });
}
