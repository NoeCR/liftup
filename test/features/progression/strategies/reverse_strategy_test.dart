import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/reverse_progression_strategy.dart';

void main() {
  test('ReverseProgressionStrategy decreases weight and increases reps', () {
    final strategy = ReverseProgressionStrategy();
    final now = DateTime.now();
    final cfg = ProgressionConfig(
      id: 'cfg',
      isGlobal: true,
      type: ProgressionType.reverse,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 1.0,
      customParameters: const {},
      startDate: now,
      endDate: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final st = ProgressionState(
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
    final res = strategy.calculate(
      config: cfg,
      state: st,
      routineId: 'test-routine',
      currentWeight: 100,
      currentReps: 10,
      currentSets: 4,
    );
    expect(res.incrementApplied, true);
    expect(res.newWeight, 97.5);
    expect(res.newReps, 11);
  });

  test('blocks progression when exercise is locked', () {
    final strategy = ReverseProgressionStrategy();
    final now = DateTime.now();
    final cfg = ProgressionConfig(
      id: 'cfg',
      isGlobal: true,
      type: ProgressionType.reverse,
      unit: ProgressionUnit.session,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: ProgressionTarget.reps,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 1.0,
      customParameters: const {},
      startDate: now,
      endDate: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final st = ProgressionState(
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
}
