import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';

void main() {
  group('AutoregulatedProgressionStrategy', () {
    final strategy = AutoregulatedProgressionStrategy();

    ProgressionConfig _config() {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.autoregulated,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: ProgressionTarget.reps,
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.9,
        customParameters: const {
          'target_rpe': 8.0,
          'rpe_threshold': 0.5,
          'target_reps': 10,
          'max_reps': 12,
          'min_reps': 8,
        },
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState _state({int session = 1, Map<String, dynamic>? hist}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: session,
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
        baseWeight: 100,
        baseReps: 10,
        baseSets: 4,
        sessionHistory: hist ?? const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );
    }

    test('RPE low -> increase weight', () {
      final cfg = _config();
      final st = _state(
        session: 1,
        hist: const {
          'session_1': {'reps': 12},
        },
      );
      final res = strategy.calculate(config: cfg, state: st, currentWeight: 100, currentReps: 10, currentSets: 4);
      expect(res.newWeight, 102.5);
    });

    test('RPE high -> reduce weight and clamp min reps', () {
      final cfg = _config();
      final st = _state(
        session: 1,
        hist: const {
          'session_1': {'reps': 6},
        },
      );
      final res = strategy.calculate(config: cfg, state: st, currentWeight: 100, currentReps: 6, currentSets: 4);
      expect(res.newWeight, 98.75);
      expect(res.newReps, 8);
    });
  });
}
