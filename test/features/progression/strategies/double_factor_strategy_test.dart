import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/double_factor_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  test('DoubleFactorProgressionStrategy adjusts by fitness/fatigue ratio', () {
    final strategy = DoubleFactorProgressionStrategy();
    final now = DateTime.now();
    final cfg = ProgressionConfig(
      id: 'cfg',
      isGlobal: true,
      type: ProgressionType.doubleFactor,
      unit: ProgressionUnit.week,
      primaryTarget: ProgressionTarget.weight,
      secondaryTarget: null,
      incrementValue: 2.5,
      incrementFrequency: 1,
      cycleLength: 4,
      deloadWeek: 0,
      deloadPercentage: 0.9,
      customParameters: const {'fitness_gain': 0.2, 'fatigue_decay': 0.05},
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
      customData: const {'fitness': 1.0, 'fatigue': 0.0},
    );
    final res = strategy.calculate(config: cfg, state: st, currentWeight: 100, currentReps: 10, currentSets: 4);
    expect(res.incrementApplied, true);
    expect(res.newWeight, greaterThan(100));
  });
}
