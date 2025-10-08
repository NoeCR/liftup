import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  group('WaveProgressionStrategy', () {
    final strategy = WaveProgressionStrategy();

    ProgressionConfig _config() {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.wave,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.volume,
        incrementValue: 5.0,
        incrementFrequency: 3,
        cycleLength: 9,
        deloadWeek: 3,
        deloadPercentage: 0.7,
        customParameters: const {},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState _state({int week = 1}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        currentCycle: 1,
        currentWeek: week,
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

    test('week 1 high intensity', () {
      final cfg = _config();
      final st = _state(week: 1);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.newWeight, 105);
      expect(res.newReps, 9);
    });

    test('week 3 deload', () {
      final cfg = _config();
      final st = _state(week: 3);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        currentWeight: 120,
        currentReps: 10,
        currentSets: 4,
      );
      expect(res.newWeight, 70.0); // baseWeight * deloadPercentage = 100 * 0.7
      expect(res.newSets, 3);
    });
  });
}
