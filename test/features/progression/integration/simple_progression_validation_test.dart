import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/common/enums/muscle_group_enum.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/progression/configs/preset_progression_configs.dart';
import 'package:liftly/features/progression/models/progression_config.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/strategies/strategies/linear_progression_strategy.dart';

/// Tests simplificados para validar la funcionalidad de progresión
/// Estos tests se enfocan en validar que AdaptiveIncrementConfig funcione correctamente
/// con las estrategias de progresión en ciclos cortos
void main() {
  group('Simple Progression Validation Tests', () {
    late List<Exercise> testExercises;
    late LinearProgressionStrategy strategy;

    setUpAll(() {
      testExercises = _createTestExercises();
      strategy = LinearProgressionStrategy();
    });

    group('AdaptiveIncrementConfig Integration', () {
      test('Barbell multi-joint should use correct increment', () {
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.multiJoint &&
              e.loadType == LoadType.barbell,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final result = _testSingleSession(exercise, preset, strategy);

        // Barbell multi-joint should increment by 3.75kg for intermediate level
        expect(result.weightIncrement, equals(3.75));
        expect(result.incrementApplied, isTrue);
      });

      test('Dumbbell isolation should use correct increment', () {
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.isolation &&
              e.loadType == LoadType.dumbbell,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final result = _testSingleSession(exercise, preset, strategy);

        // Dumbbell isolation should increment by 0.875kg for intermediate level
        expect(result.weightIncrement, equals(0.875));
        expect(result.incrementApplied, isTrue);
      });

      test('Machine multi-joint should use correct increment', () {
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.multiJoint &&
              e.loadType == LoadType.machine,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final result = _testSingleSession(exercise, preset, strategy);

        // Machine multi-joint should increment by 5.0kg for intermediate level
        expect(result.weightIncrement, equals(5.0));
        expect(result.incrementApplied, isTrue);
      });

      test('Bodyweight exercises should not increment weight', () {
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.multiJoint &&
              e.loadType == LoadType.bodyweight,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final result = _testSingleSession(exercise, preset, strategy);

        // Bodyweight exercises should not increment weight
        expect(result.weightIncrement, equals(0.0));
        // Note: incrementApplied might be true even with 0 increment due to strategy logic
      });

      test('Resistance band exercises should not increment weight', () {
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.isolation &&
              e.loadType == LoadType.resistanceBand,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final result = _testSingleSession(exercise, preset, strategy);

        // Resistance band exercises should not increment weight
        expect(result.weightIncrement, equals(0.0));
        // Note: incrementApplied might be true even with 0 increment due to strategy logic
      });
    });

    group('Preset Integration', () {
      test(
        'All presets should use AdaptiveIncrementConfig (incrementValue = 0)',
        () {
          final presets = [
            PresetProgressionConfigs.createLinearHypertrophyPreset(),
            PresetProgressionConfigs.createLinearStrengthPreset(),
            PresetProgressionConfigs.createLinearEndurancePreset(),
            PresetProgressionConfigs.createLinearPowerPreset(),
          ];

          for (final preset in presets) {
            // All presets should use AdaptiveIncrementConfig (incrementValue = 0)
            expect(preset.incrementValue, equals(0));
          }
        },
      );

      test('Presets should maintain their specific characteristics', () {
        final hypertrophyPreset =
            PresetProgressionConfigs.createLinearHypertrophyPreset();
        final strengthPreset =
            PresetProgressionConfigs.createLinearStrengthPreset();
        final endurancePreset =
            PresetProgressionConfigs.createLinearEndurancePreset();
        final powerPreset = PresetProgressionConfigs.createLinearPowerPreset();

        // Test rep ranges
        expect(hypertrophyPreset.minReps, equals(8));
        expect(hypertrophyPreset.maxReps, equals(12));
        expect(strengthPreset.minReps, equals(3));
        expect(strengthPreset.maxReps, equals(6));
        expect(endurancePreset.minReps, equals(12));
        expect(endurancePreset.maxReps, equals(20));
        expect(powerPreset.minReps, equals(3));
        expect(powerPreset.maxReps, equals(6));

        // Test base sets
        expect(hypertrophyPreset.baseSets, equals(3));
        expect(strengthPreset.baseSets, equals(4));
        expect(endurancePreset.baseSets, equals(3));
        expect(powerPreset.baseSets, equals(4));
      });
    });

    group('Multi-session Simulation', () {
      test('Linear progression should follow 4-week cycle with deload', () {
        final exercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.multiJoint &&
              e.loadType == LoadType.barbell,
        );
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final results = _testMultipleSessions(exercise, preset, strategy, 5);

        // Should have 5 sessions
        expect(results.length, equals(5));

        // First 3 sessions should increment (weeks 1-3 of cycle)
        expect(results[0].weightIncrement, equals(3.75));
        expect(results[0].incrementApplied, isTrue);
        expect(results[0].isDeload, isFalse);

        expect(results[1].weightIncrement, equals(3.75));
        expect(results[1].incrementApplied, isTrue);
        expect(results[1].isDeload, isFalse);

        expect(results[2].weightIncrement, equals(3.75));
        expect(results[2].incrementApplied, isTrue);
        expect(results[2].isDeload, isFalse);

        // 4th session should be deload (week 4 of cycle)
        expect(
          results[3].weightIncrement,
          lessThan(0),
        ); // Negative increment (deload)
        expect(results[3].isDeload, isTrue);

        // 5th session should increment again (week 1 of new cycle)
        expect(results[4].weightIncrement, equals(3.75));
        expect(results[4].incrementApplied, isTrue);
        expect(results[4].isDeload, isFalse);
      });

      test(
        'Bodyweight progression should not increment weight but may increment series',
        () {
          final exercise = testExercises.firstWhere(
            (e) =>
                e.exerciseType == ExerciseType.multiJoint &&
                e.loadType == LoadType.bodyweight,
          );
          final preset =
              PresetProgressionConfigs.createLinearHypertrophyPreset();

          final results = _testMultipleSessions(exercise, preset, strategy, 5);

          // Should not increment weight
          for (final result in results) {
            expect(result.weightIncrement, equals(0.0));
            expect(result.finalWeight, equals(100.0)); // Weight stays the same
          }
        },
      );
    });

    group('Edge Cases', () {
      test('Null exercise should handle gracefully', () {
        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();
        final state = _createTestState();

        // Should not throw error with null exercise
        expect(() {
          strategy.calculate(
            config: preset,
            state: state,
            routineId: 'test',
            currentWeight: 100.0,
            currentReps: 8,
            currentSets: 3,
            exercise: null,
          );
        }, returnsNormally);
      });

      test('Different exercise types should have different increments', () {
        final multiJointExercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.multiJoint &&
              e.loadType == LoadType.barbell,
        );
        final isolationExercise = testExercises.firstWhere(
          (e) =>
              e.exerciseType == ExerciseType.isolation &&
              e.loadType == LoadType.barbell,
        );

        final preset = PresetProgressionConfigs.createLinearHypertrophyPreset();

        final multiJointResult = _testSingleSession(
          multiJointExercise,
          preset,
          strategy,
        );
        final isolationResult = _testSingleSession(
          isolationExercise,
          preset,
          strategy,
        );

        // Multi-joint should have same or larger increment than isolation
        expect(
          multiJointResult.weightIncrement,
          greaterThanOrEqualTo(isolationResult.weightIncrement),
        );
      });
    });
  });
}

/// Helper function para crear ejercicios de prueba
List<Exercise> _createTestExercises() {
  final now = DateTime.now();
  final exercises = <Exercise>[];

  // Crear ejercicios para todas las combinaciones de ExerciseType y LoadType
  for (final exerciseType in ExerciseType.values) {
    for (final loadType in LoadType.values) {
      exercises.add(
        Exercise(
          id: 'test-${exerciseType.name}-${loadType.name}',
          name: 'Test ${exerciseType.name} ${loadType.name}',
          description:
              'Test exercise for ${exerciseType.name} ${loadType.name}',
          imageUrl: '',
          muscleGroups:
              exerciseType == ExerciseType.multiJoint
                  ? [MuscleGroup.pectoralMajor]
                  : [MuscleGroup.bicepsLongHead],
          tips: [],
          commonMistakes: [],
          category:
              exerciseType == ExerciseType.multiJoint
                  ? ExerciseCategory.chest
                  : ExerciseCategory.biceps,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: now,
          updatedAt: now,
          exerciseType: exerciseType,
          loadType: loadType,
        ),
      );
    }
  }

  return exercises;
}

/// Helper function para crear un estado de prueba
ProgressionState _createTestState() {
  return ProgressionState(
    id: 'test',
    progressionConfigId: 'test-config',
    exerciseId: 'test-exercise',
    routineId: 'test',
    currentCycle: 1,
    currentWeek: 1,
    currentSession: 1,
    currentWeight: 100.0,
    currentReps: 8,
    currentSets: 3,
    baseWeight: 100.0,
    baseReps: 8,
    baseSets: 3,
    sessionHistory: {},
    lastUpdated: DateTime.now(),
    isDeloadWeek: false,
    customData: {},
  );
}

/// Helper function para testear una sola sesión
SessionTestResult _testSingleSession(
  Exercise exercise,
  ProgressionConfig preset,
  LinearProgressionStrategy strategy,
) {
  final state = _createTestState();

  final result = strategy.calculate(
    config: preset,
    state: state,
    routineId: 'test',
    currentWeight: 100.0,
    currentReps: preset.minReps,
    currentSets: preset.baseSets,
    exercise: exercise,
  );

  return SessionTestResult(
    weightIncrement: result.newWeight - 100.0,
    finalWeight: result.newWeight,
    incrementApplied: result.incrementApplied,
    isDeload: result.isDeload,
    reason: result.reason,
  );
}

/// Helper function para testear múltiples sesiones
List<SessionTestResult> _testMultipleSessions(
  Exercise exercise,
  ProgressionConfig preset,
  LinearProgressionStrategy strategy,
  int sessionCount,
) {
  final results = <SessionTestResult>[];
  var currentWeight = 100.0;

  for (int session = 1; session <= sessionCount; session++) {
    final state = ProgressionState(
      id: 'test',
      progressionConfigId: 'test-config',
      exerciseId: exercise.id,
      routineId: 'test',
      currentCycle: 1,
      currentWeek: 1,
      currentSession: session,
      currentWeight: currentWeight,
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

    final result = strategy.calculate(
      config: preset,
      state: state,
      routineId: 'test',
      currentWeight: currentWeight,
      currentReps: preset.minReps,
      currentSets: preset.baseSets,
      exercise: exercise,
    );

    final sessionResult = SessionTestResult(
      weightIncrement: result.newWeight - currentWeight,
      finalWeight: result.newWeight,
      incrementApplied: result.incrementApplied,
      isDeload: result.isDeload,
      reason: result.reason,
    );

    results.add(sessionResult);
    currentWeight = result.newWeight;
  }

  return results;
}

/// Clase para resultados de tests de sesión
class SessionTestResult {
  final double weightIncrement;
  final double finalWeight;
  final bool incrementApplied;
  final bool isDeload;
  final String reason;

  const SessionTestResult({
    required this.weightIncrement,
    required this.finalWeight,
    required this.incrementApplied,
    required this.isDeload,
    required this.reason,
  });
}
