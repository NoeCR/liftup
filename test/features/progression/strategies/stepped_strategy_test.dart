import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/stepped_progression_strategy.dart';

void main() {
  group('SteppedProgressionStrategy', () {
    final strategy = SteppedProgressionStrategy();

    ProgressionConfig config({int deloadWeek = 0}) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.stepped,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: deloadWeek,
        deloadPercentage: 0.8,
        customParameters: const {'accumulation_weeks': 3},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState state({int week = 2, double baseW = 100}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: week,
        currentSession: 1,
        currentWeight: baseW,
        currentReps: 10,
        currentSets: 4,
        baseWeight: baseW,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    test('accumulation adds based on week', () {
      final cfg = config();
      final st = state(week: 2, baseW: 100);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.incrementApplied, true);
      expect(res.newWeight, 100 + 2 * 2.5);
    });

    test('deload applied at deloadWeek', () {
      final cfg = config(deloadWeek: 2);
      final st = state(week: 2, baseW: 100);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 110,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.newWeight, closeTo(108.0, 0.0001)); // Deload: 100 + ((110 - 100) * 0.8) = 100 + (10 * 0.8) = 108.0
      expect(res.newSets, 3);
    });

    test('blocks progression when exercise is locked', () {
      final cfg = config();
      final st = state();
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
        isExerciseLocked: true,
      );
      expect(res.incrementApplied, false);
      expect(res.newWeight, 100);
      expect(res.newReps, 10);
      expect(res.newSets, 4);
      expect(res.reason, contains('blocked'));
    });
  });
}
