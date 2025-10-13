import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

/// Test de debug para entender el comportamiento de la progresión
void main() {
  group('Debug Progression Tests', () {
    test('Debug single session with barbell multi-joint', () {
      final exercise = Exercise(
        id: 'test-barbell-multijoint',
        name: 'Test Barbell Multi-joint',
        description: 'Test exercise',
        imageUrl: '',
        muscleGroups: [MuscleGroup.pectoralMajor],
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

      final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
      final strategy = LinearProgressionStrategy();

      final state = ProgressionState(
        id: 'test',
        progressionConfigId: 'test-config',
        exerciseId: exercise.id,
        routineId: 'test',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 100.0,
        currentReps: preset.minReps,
        currentSets: preset.baseSets,
        baseWeight: 100.0,
        baseReps: preset.minReps,
        baseSets: preset.baseSets,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );

      print('Initial state:');
      print('  Weight: ${state.currentWeight}');
      print('  Reps: ${state.currentReps}');
      print('  Sets: ${state.currentSets}');
      print('  Session: ${state.currentSession}');
      print('  Cycle: ${state.currentCycle}');
      print('  Week: ${state.currentWeek}');
      print('  IsDeloadWeek: ${state.isDeloadWeek}');

      final result = strategy.calculate(
        config: preset,
        state: state,
        routineId: 'test',
        currentWeight: 100.0,
        currentReps: preset.minReps,
        currentSets: preset.baseSets,
        exercise: exercise,
      );

      print('\nResult:');
      print('  New Weight: ${result.newWeight}');
      print('  New Reps: ${result.newReps}');
      print('  New Sets: ${result.newSets}');
      print('  Increment Applied: ${result.incrementApplied}');
      print('  Is Deload: ${result.isDeload}');
      print('  Reason: ${result.reason}');

      print('\nPreset config:');
      print('  Increment Value: ${preset.incrementValue}');
      print('  Increment Frequency: ${preset.incrementFrequency}');
      print('  Cycle Length: ${preset.cycleLength}');
      print('  Deload Week: ${preset.deloadWeek}');
      print('  Deload Percentage: ${preset.deloadPercentage}');
      print('  Min Reps: ${preset.minReps}');
      print('  Max Reps: ${preset.maxReps}');
      print('  Base Sets: ${preset.baseSets}');

      // Basic assertions
      expect(result.newWeight, isA<double>());
      expect(result.newReps, isA<int>());
      expect(result.newSets, isA<int>());
    });

    test('Debug multiple sessions to understand deload behavior', () {
      final exercise = Exercise(
        id: 'test-barbell-multijoint',
        name: 'Test Barbell Multi-joint',
        description: 'Test exercise',
        imageUrl: '',
        muscleGroups: [MuscleGroup.pectoralMajor],
        tips: [],
        commonMistakes: [],
        category: ExerciseCategory.chest,
        difficulty: ExerciseDifficulty.intermediate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        exerciseType: ExerciseType.multiJoint,
        loadType: LoadType.barbell,
      );

      final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
      final strategy = LinearProgressionStrategy();

      var currentWeight = 100.0;
      var currentReps = preset.minReps;
      var currentSets = preset.baseSets;

      print('Testing multiple sessions:');
      print('Preset deload week: ${preset.deloadWeek}');
      print('Preset deload percentage: ${preset.deloadPercentage}');

      for (int session = 1; session <= 10; session++) {
        final state = ProgressionState(
          id: 'test',
          progressionConfigId: 'test-config',
          exerciseId: exercise.id,
          routineId: 'test',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: session,
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          baseWeight: 100.0,
          baseReps: preset.minReps,
          baseSets: preset.baseSets,
          sessionHistory: {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          customData: {},
        );

        final result = strategy.calculate(
          config: preset,
          state: state,
          routineId: 'test',
          currentWeight: currentWeight,
          currentReps: currentReps,
          currentSets: currentSets,
          exercise: exercise,
        );

        final weightChange = result.newWeight - currentWeight;

        print(
          'Session $session: ${currentWeight}kg -> ${result.newWeight}kg (${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}kg) - ${result.isDeload ? 'DELOAD' : 'NORMAL'} - ${result.reason}',
        );

        currentWeight = result.newWeight;
        currentReps = result.newReps;
        currentSets = result.newSets;
      }
    });
  });
}
