import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/progression_type_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

void main() {
  group('Adaptive Experience Integration', () {
    late Exercise exercise;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      exercise = Exercise(
        id: 'ex',
        name: 'Bench',
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
    });

    test('incrementos sin adaptive_experience (fallback intermedio)', () {
      final config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 0,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.8,
        customParameters: const {},
        startDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        minReps: 6,
        maxReps: 12,
        baseSets: 3,
      );

      final state = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'r',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      final strategy = LinearProgressionStrategy();
      final res = strategy.calculate(
        config: config,
        state: state,
        routineId: 'r',
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        exercise: exercise,
      );

      // Para barbell multi-joint, nivel intermedio ≈ 6.0 kg
      expect(res.newWeight, closeTo(106.0, 0.001));
    });

    test('incrementos con adaptive_experience activo (initiated en primer ciclo)', () {
      final config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 0,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.8,
        customParameters: const {'adaptive_experience': true},
        startDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        minReps: 6,
        maxReps: 12,
        baseSets: 3,
      );

      final state = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'r',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      final strategy = LinearProgressionStrategy();
      final res = strategy.calculate(
        config: config,
        state: state,
        routineId: 'r',
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        exercise: exercise,
      );

      // initiated: usa el mínimo del rango (5.0kg) para barbell multi-joint
      expect(res.newWeight, closeTo(105.0, 0.001));
    });

    test('incrementos con adaptive_experience activo (advanced a partir de 4º ciclo)', () {
      final config = ProgressionConfig(
        id: 'cfg',
        isGlobal: true,
        type: ProgressionType.linear,
        unit: ProgressionUnit.week,
        primaryTarget: ProgressionTarget.weight,
        secondaryTarget: null,
        incrementValue: 0,
        incrementFrequency: 1,
        cycleLength: 4,
        deloadWeek: 0,
        deloadPercentage: 0.8,
        customParameters: const {'adaptive_experience': true},
        startDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        minReps: 6,
        maxReps: 12,
        baseSets: 3,
      );

      final state = ProgressionState(
        id: 'st',
        progressionConfigId: 'cfg',
        exerciseId: 'ex',
        routineId: 'r',
        currentCycle: 4, // 4º ciclo ⇒ advanced
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        baseWeight: 100.0,
        baseReps: 8,
        baseSets: 3,
        sessionHistory: const {},
        lastUpdated: now,
        isDeloadWeek: false,
        oneRepMax: null,
        customData: const {},
      );

      final strategy = LinearProgressionStrategy();
      final res = strategy.calculate(
        config: config,
        state: state,
        routineId: 'r',
        currentWeight: 100.0,
        currentReps: 8,
        currentSets: 3,
        exercise: exercise,
      );

      // advanced: usa el máximo del rango (7.0kg) para barbell multi-joint
      expect(res.newWeight, closeTo(107.0, 0.001));
    });
  });
}
