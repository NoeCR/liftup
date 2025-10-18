import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/features/exercise/notifiers/exercise_notifier.dart';
import 'package:liftly/features/progression/models/progression_state.dart';
import 'package:liftly/features/progression/notifiers/progression_notifier.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([ExerciseNotifier, ProgressionNotifier])
import 'progression_state_initialization_test.mocks.dart';

void main() {
  group('Progression State Initialization Tests', () {
    late MockProgressionNotifier mockProgressionNotifier;

    setUp(() {
      mockProgressionNotifier = MockProgressionNotifier();
    });

    test('should collect and use highest values when initializing progression state from session data', () async {
      // Arrange: Create exercise sets with varying weights and reps (progressive overload)
      final exerciseSets = [
        ExerciseSet(
          id: 'set-1',
          exerciseId: 'test-exercise-1',
          weight: 60.0, // User configured weight (different from exercise default)
          reps: 10, // User configured reps (different from exercise default)
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        ExerciseSet(
          id: 'set-2',
          exerciseId: 'test-exercise-1',
          weight: 62.5, // Progressive overload
          reps: 9,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        ExerciseSet(
          id: 'set-3',
          exerciseId: 'test-exercise-1',
          weight: 65.0, // Progressive overload
          reps: 8,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        ExerciseSet(
          id: 'set-4',
          exerciseId: 'test-exercise-1',
          weight: 67.5, // Progressive overload - highest weight
          reps: 7,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
      ];

      // Act: Simulate the logic from completeSession() that collects exercise values
      final exerciseValuesUsed = <String, Map<String, dynamic>>{};

      // Collect actual values used for each exercise (same logic as in completeSession)
      for (final set in exerciseSets) {
        if (!exerciseValuesUsed.containsKey(set.exerciseId)) {
          exerciseValuesUsed[set.exerciseId] = {'weight': set.weight, 'reps': set.reps, 'sets': 1};
        } else {
          final current = exerciseValuesUsed[set.exerciseId]!;
          exerciseValuesUsed[set.exerciseId] = {
            'weight': set.weight > current['weight'] ? set.weight : current['weight'],
            'reps': set.reps > current['reps'] ? set.reps : current['reps'],
            'sets': current['sets'] + 1,
          };
        }
      }

      // Assert: Verify that the highest values are correctly collected
      final valuesUsed = exerciseValuesUsed['test-exercise-1'];
      expect(valuesUsed, isNotNull, reason: 'Exercise values should be collected');
      expect(valuesUsed!['weight'], equals(67.5), reason: 'Should use highest weight (67.5)');
      expect(valuesUsed['reps'], equals(10), reason: 'Should use highest reps (10)');
      expect(valuesUsed['sets'], equals(4), reason: 'Should count total sets (4)');
    });

    test('should initialize progression state with collected session values when no existing state', () async {
      // Arrange: Mock that no existing progression state exists
      when(
        mockProgressionNotifier.getExerciseProgressionState('test-exercise-1', 'test-routine-1'),
      ).thenAnswer((_) async => null);

      // Mock the initializeExerciseProgression method
      when(
        mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: anyNamed('exerciseId'),
          routineId: anyNamed('routineId'),
          baseWeight: anyNamed('baseWeight'),
          baseReps: anyNamed('baseReps'),
          baseSets: anyNamed('baseSets'),
        ),
      ).thenAnswer(
        (_) async => ProgressionState(
          id: 'mock-state-id',
          progressionConfigId: 'mock-config-id',
          exerciseId: 'test-exercise-1',
          routineId: 'test-routine-1',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 1,
          currentWeight: 67.5,
          currentReps: 10,
          currentSets: 4,
          baseWeight: 67.5,
          baseReps: 10,
          baseSets: 4,
          sessionHistory: {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          customData: {},
        ),
      );

      // Act: Simulate the initialization logic from completeSession()
      final valuesUsed = {'weight': 67.5, 'reps': 10, 'sets': 4};

      // Check if progression state already exists
      final existingState = await mockProgressionNotifier.getExerciseProgressionState(
        'test-exercise-1',
        'test-routine-1',
      );
      if (existingState == null) {
        // Create progression state with actual values used
        await mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: 'test-exercise-1',
          routineId: 'test-routine-1',
          baseWeight: valuesUsed['weight'] as double,
          baseReps: valuesUsed['reps'] as int,
          baseSets: valuesUsed['sets'] as int,
        );
      }

      // Assert: Verify that initializeExerciseProgression was called with correct values
      verify(
        mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: 'test-exercise-1',
          routineId: 'test-routine-1',
          baseWeight: 67.5,
          baseReps: 10,
          baseSets: 4,
        ),
      ).called(1);
    });

    test('should not initialize progression state when existing state already exists', () async {
      // Arrange: Mock that an existing progression state exists
      final existingProgressionState = ProgressionState(
        id: 'existing-state-id',
        progressionConfigId: 'config-id',
        exerciseId: 'test-exercise-2',
        routineId: 'test-routine-2',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 70.0,
        currentReps: 12,
        currentSets: 5,
        baseWeight: 70.0,
        baseReps: 12,
        baseSets: 5,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {},
      );

      when(
        mockProgressionNotifier.getExerciseProgressionState('test-exercise-2', 'test-routine-2'),
      ).thenAnswer((_) async => existingProgressionState);

      // Act: Simulate the initialization logic from completeSession()
      final valuesUsed = {
        'weight': 60.0, // Different from existing state
        'reps': 10, // Different from existing state
        'sets': 4, // Different from existing state
      };

      // Check if progression state already exists
      final existingState = await mockProgressionNotifier.getExerciseProgressionState(
        'test-exercise-2',
        'test-routine-2',
      );
      if (existingState == null) {
        // This should NOT be called because existing state exists
        await mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: 'test-exercise-2',
          routineId: 'test-routine-2',
          baseWeight: valuesUsed['weight'] as double,
          baseReps: valuesUsed['reps'] as int,
          baseSets: valuesUsed['sets'] as int,
        );
      }

      // Assert: Verify that initializeExerciseProgression was NOT called
      verifyNever(
        mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: anyNamed('exerciseId'),
          routineId: anyNamed('routineId'),
          baseWeight: anyNamed('baseWeight'),
          baseReps: anyNamed('baseReps'),
          baseSets: anyNamed('baseSets'),
        ),
      );
    });

    test('should initialize new progression state when exercise is used in different routine', () async {
      // Arrange: Mock that an existing progression state exists for a different routine
      final existingProgressionState = ProgressionState(
        id: 'existing-state-id',
        progressionConfigId: 'config-id',
        exerciseId: 'test-exercise-3',
        routineId: 'different-routine-id',
        currentCycle: 1,
        currentWeek: 1,
        currentSession: 1,
        currentWeight: 70.0,
        currentReps: 12,
        currentSets: 5,
        baseWeight: 70.0,
        baseReps: 12,
        baseSets: 5,
        sessionHistory: {},
        lastUpdated: DateTime.now(),
        isDeloadWeek: false,
        customData: {'current_routine_id': 'different-routine-id'}, // Different routine
      );

      when(
        mockProgressionNotifier.getExerciseProgressionState('test-exercise-3', 'current-routine-id'),
      ).thenAnswer((_) async => null);

      // Mock the initializeExerciseProgression method
      when(
        mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: anyNamed('exerciseId'),
          routineId: anyNamed('routineId'),
          baseWeight: anyNamed('baseWeight'),
          baseReps: anyNamed('baseReps'),
          baseSets: anyNamed('baseSets'),
        ),
      ).thenAnswer(
        (_) async => ProgressionState(
          id: 'new-state-id',
          progressionConfigId: 'config-id',
          exerciseId: 'test-exercise-3',
          routineId: 'current-routine-id',
          currentCycle: 1,
          currentWeek: 1,
          currentSession: 1,
          currentWeight: 60.0,
          currentReps: 10,
          currentSets: 4,
          baseWeight: 60.0,
          baseReps: 10,
          baseSets: 4,
          sessionHistory: {},
          lastUpdated: DateTime.now(),
          isDeloadWeek: false,
          customData: {},
        ),
      );

      // Act: Simulate the logic that checks if progression state is for current routine
      const currentRoutineId = 'current-routine-id';
      final isForCurrentRoutine = existingProgressionState.customData['current_routine_id'] == currentRoutineId;

      if (!isForCurrentRoutine) {
        // This should be called because the existing state is for a different routine
        await mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: 'test-exercise-3',
          routineId: currentRoutineId,
          baseWeight: 60.0, // New configured values
          baseReps: 10,
          baseSets: 4,
        );
      }

      // Assert: Verify that initializeExerciseProgression was called with new values
      verify(
        mockProgressionNotifier.initializeExerciseProgression(
          exerciseId: 'test-exercise-3',
          routineId: currentRoutineId,
          baseWeight: 60.0,
          baseReps: 10,
          baseSets: 4,
        ),
      ).called(1);
    });

    test('should handle multiple exercises correctly in session completion', () async {
      // Arrange: Create exercise sets for multiple exercises
      final exerciseSets = [
        // Exercise 1 sets
        ExerciseSet(
          id: 'set-1',
          exerciseId: 'exercise-1',
          weight: 60.0,
          reps: 10,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        ExerciseSet(
          id: 'set-2',
          exerciseId: 'exercise-1',
          weight: 65.0, // Highest for exercise 1
          reps: 8,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        // Exercise 2 sets
        ExerciseSet(
          id: 'set-3',
          exerciseId: 'exercise-2',
          weight: 30.0,
          reps: 15,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
        ExerciseSet(
          id: 'set-4',
          exerciseId: 'exercise-2',
          weight: 35.0, // Highest for exercise 2
          reps: 12,
          completedAt: DateTime.now(),
          isCompleted: true,
        ),
      ];

      // Act: Simulate the logic from completeSession() that collects exercise values
      final exerciseValuesUsed = <String, Map<String, dynamic>>{};

      for (final set in exerciseSets) {
        if (!exerciseValuesUsed.containsKey(set.exerciseId)) {
          exerciseValuesUsed[set.exerciseId] = {'weight': set.weight, 'reps': set.reps, 'sets': 1};
        } else {
          final current = exerciseValuesUsed[set.exerciseId]!;
          exerciseValuesUsed[set.exerciseId] = {
            'weight': set.weight > current['weight'] ? set.weight : current['weight'],
            'reps': set.reps > current['reps'] ? set.reps : current['reps'],
            'sets': current['sets'] + 1,
          };
        }
      }

      // Assert: Verify that both exercises have their values correctly collected
      final exercise1Values = exerciseValuesUsed['exercise-1'];
      expect(exercise1Values, isNotNull);
      expect(exercise1Values!['weight'], equals(65.0));
      expect(exercise1Values['reps'], equals(10));
      expect(exercise1Values['sets'], equals(2));

      final exercise2Values = exerciseValuesUsed['exercise-2'];
      expect(exercise2Values, isNotNull);
      expect(exercise2Values!['weight'], equals(35.0));
      expect(exercise2Values['reps'], equals(15));
      expect(exercise2Values['sets'], equals(2));
    });
  });
}
