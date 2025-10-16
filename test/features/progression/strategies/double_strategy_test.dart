import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/double_progression_strategy.dart';

void main() {
  group('DoubleProgressionStrategy', () {
    final strategy = DoubleProgressionStrategy();
    final now = DateTime.now();

    // Crear ejercicio de prueba
    final testExercise = Exercise(
      id: 'test-exercise',
      name: 'Test Exercise',
      description: 'Test exercise for progression',
      imageUrl: '',
      muscleGroups: [MuscleGroup.pectoralMajor],
      tips: [],
      commonMistakes: [],
      category: ExerciseCategory.chest,
      difficulty: ExerciseDifficulty.intermediate,
      createdAt: now,
      updatedAt: now,
      exerciseType: ExerciseType.multiJoint,
      loadType: LoadType.barbell,
    );

    ProgressionConfig config({
      double increment = 2.5,
      int cycle = 4,
      int deloadWeek = 0,
    }) {
      final now = DateTime.now();
      return ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.double,
        unit: ProgressionUnit.session,
        primaryTarget: ProgressionTarget.reps,
        secondaryTarget: ProgressionTarget.weight,
        incrementValue: increment,
        incrementFrequency: 1,
        cycleLength: cycle,
        minReps: 8,
        maxReps: 12,
        baseSets: 3,
        deloadWeek: deloadWeek,
        deloadPercentage: 0.9,
        customParameters: const {'min_reps': 8, 'max_reps': 12},
        startDate: now,
        endDate: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }

    ProgressionState state({
      int session = 1,
      int reps = 10,
      double weight = 100,
    }) {
      final now = DateTime.now();
      return ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'test-routine-1',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: session,
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

    test('increase reps until max', () {
      final cfg = config();
      final st = state(reps: 10, weight: 100);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 10,
        currentSets: 4,
        exercise: testExercise,
      );
      expect(res.incrementApplied, true);
      expect(res.newReps, 11);
      expect(res.newWeight, 100);
    });

    test('increase weight and reset reps when max reached', () {
      final cfg = config(increment: 2.5);
      final st = state(reps: 12, weight: 100);
      final res = strategy.calculate(
        config: cfg,
        state: st,
        routineId: 'test-routine',
        currentWeight: 100,
        currentReps: 12,
        currentSets: 4,
        exercise: testExercise,
      );
      expect(res.incrementApplied, true);
      expect(
        res.newWeight,
        103.75,
      ); // incrementValue adaptativo (3.75kg para barbell multiJoint)
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
