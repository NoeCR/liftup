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

      // Para barbell multi-joint, nivel intermedio ≈ 6.25 kg
      expect(res.newWeight, closeTo(106.25, 0.001));
    });

    test('incrementos con ejercicio beginner (deriva a initiated)', () {
      // Cambiar ejercicio a beginner para derivar a initiated
      exercise = Exercise(
        id: 'ex',
        name: 'Bench',
        description: '',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.beginner,
        createdAt: now,
        updatedAt: now,
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

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

      // initiated: usa el mínimo del rango (5.0kg) para barbell multi-joint
      expect(res.newWeight, closeTo(105.0, 0.001));
    });

    test('incrementos con ejercicio advanced (deriva a advanced)', () {
      // Cambiar ejercicio a advanced para derivar a advanced
      exercise = Exercise(
        id: 'ex',
        name: 'Bench',
        description: '',
        imageUrl: '',
        muscleGroups: const [],
        tips: const [],
        commonMistakes: const [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.advanced,
        createdAt: now,
        updatedAt: now,
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

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
        currentCycle: 1, // Ciclo 1
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

      // advanced: usa el máximo del rango (7.5kg) para barbell multi-joint
      expect(res.newWeight, closeTo(107.5, 0.001));
    });
  });
}
