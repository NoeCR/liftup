import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/wave_progression_strategy.dart';

void main() {
  group('WaveProgressionStrategy', () {
    final strategy = WaveProgressionStrategy();

    Exercise ex() {
      final now = DateTime.now();
      return Exercise(
        id: 'ex',
        name: 'Test',
        description: '',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: now,
        updatedAt: now,
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );
    }

    ProgressionConfig config() {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.wave,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.volume, // Cambiar a volume para que sea hypertrophy
        secondaryTarget: ProgressionTarget.reps, // Cambiar a reps para hypertrophy
        incrementValue: 5.0,
        incrementFrequency: 3,
        cycleLength: 9,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
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

    ProgressionState state({int week = 1}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
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
      final cfg = config();
      final st = state(week: 1);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
        exercise: ex(),
      );
      final inc = strategy.getIncrementValueSync(cfg, ex());
      expect(res.newWeight, 100 + inc);
      expect(res.newReps, 9);
      // clamp mínimo
      expect(res.newReps, greaterThanOrEqualTo(6));
    });

    test('week 3 deload', () {
      final cfg = config();
      final st = state(week: 3);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 120,
        currentReps: 10,
        currentSets: 4,
        exercise: ex(),
      );
      expect(res.newWeight, 114.0); // baseWeight + (increaseOverBase * 0.7) = 100 + (20*0.7)
      expect(res.newSets, 3); // 4 * 0.7 = 2.8 -> round = 3 (baseSets del sistema adaptativo)
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
