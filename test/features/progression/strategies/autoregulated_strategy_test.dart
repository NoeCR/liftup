import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/autoregulated_progression_strategy.dart';

void main() {
  group('AutoregulatedProgressionStrategy', () {
    final strategy = AutoregulatedProgressionStrategy();

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
        type: ProgressionType.autoregulated,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.volume, // Cambiar a volume para que sea hypertrophy
        secondaryTarget: ProgressionTarget.reps, // Mantener reps para hypertrophy
        incrementValue: 2.5,
        incrementFrequency: 1,
        cycleLength: 4,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
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

    ProgressionState state({int session = 1, Map<String, dynamic>? hist}) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
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
      final cfg = config();
      final st = state(
        session: 1,
        hist: const {
          'session_1': {'reps': 12},
        },
      );
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
        exercise: ex(),
      );
      expect(res.newWeight, greaterThan(100));
    });

    test('RPE high -> reduce weight and clamp min reps', () {
      final cfg = config();
      final st = state(
        session: 1,
        hist: const {
          'session_1': {'reps': 6},
        },
      );
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 6,
        currentSets: 4,
        exercise: ex(),
      );
      expect(res.newWeight, lessThan(100));
      expect(res.newReps, 6);
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
