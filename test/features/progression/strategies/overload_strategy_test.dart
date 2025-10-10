import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/overload_progression_strategy.dart';

void main() {
  group('OverloadProgressionStrategy', () {
    final strategy = OverloadProgressionStrategy();
    final now = DateTime.now();

    ProgressionConfig config({String type = 'volume'}) {
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.overload,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.9,
        customParameters: {'overload_type': type, 'overload_rate': 0.1},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState state() {
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
        baseWeight: 100,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    test('volume overload increases sets', () {
      final cfg = config(type: 'volume');
      final st = state();
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.newSets, 4 + (4 * 0.1).round());
    });

    test('intensity overload increases weight', () {
      final cfg = config(type: 'intensity');
      final st = state();
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.newWeight, closeTo(110, 10)); // allow some tolerance
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
