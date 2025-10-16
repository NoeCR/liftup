import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/home/models/routine.dart';
import 'package:liftly/features/sessions/notifiers/exercise_state_notifier.dart';

void main() {
  group('ExerciseStateNotifier', () {
    late ProviderContainer container;
    late ExerciseStateNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(exerciseStateNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('initializeExercise', () {
      test('should add exercise to state when not present', () {
        // Arrange
        final exercise = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );

        // Act
        notifier.initializeExercise(exercise);

        // Assert
        expect(notifier.state.containsKey('exercise-1'), isTrue);
        expect(notifier.state['exercise-1'], equals(exercise));
      });

      test('should not add exercise to state when already present', () {
        // Arrange
        final exercise = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );
        notifier.initializeExercise(exercise);

        final duplicateExercise = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 2, // Different order
        );

        // Act
        notifier.initializeExercise(duplicateExercise);

        // Assert
        expect(notifier.state.length, equals(1));
        expect(
          notifier.state['exercise-1']!.order,
          equals(1),
        ); // Original order preserved
      });

      test('should add multiple exercises to state', () {
        // Arrange
        final exercise1 = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );
        final exercise2 = RoutineExercise(
          id: 'exercise-2',
          exerciseId: 'base-exercise-2',
          routineSectionId: 'section-1',
          order: 2,
        );

        // Act
        notifier.initializeExercise(exercise1);
        notifier.initializeExercise(exercise2);

        // Assert
        expect(notifier.state.length, equals(2));
        expect(notifier.state['exercise-1'], equals(exercise1));
        expect(notifier.state['exercise-2'], equals(exercise2));
      });
    });

    group('getExercise', () {
      test('should return exercise when present', () {
        // Arrange
        final exercise = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );
        notifier.initializeExercise(exercise);

        // Act
        final result = notifier.getExercise('exercise-1');

        // Assert
        expect(result, equals(exercise));
      });

      test('should return null when exercise not present', () {
        // Act
        final result = notifier.getExercise('non-existent');

        // Assert
        expect(result, isNull);
      });

      test('should return null when state is empty', () {
        // Act
        final result = notifier.getExercise('exercise-1');

        // Assert
        expect(result, isNull);
      });
    });

    group('clearExerciseStates', () {
      test('should clear all exercise states', () {
        // Arrange
        final exercise1 = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );
        final exercise2 = RoutineExercise(
          id: 'exercise-2',
          exerciseId: 'base-exercise-2',
          routineSectionId: 'section-1',
          order: 2,
        );
        notifier.initializeExercise(exercise1);
        notifier.initializeExercise(exercise2);

        expect(notifier.state.length, equals(2));

        // Act
        notifier.clearExerciseStates();

        // Assert
        expect(notifier.state, isEmpty);
      });

      test('should clear empty state without error', () {
        // Act
        notifier.clearExerciseStates();

        // Assert
        expect(notifier.state, isEmpty);
      });
    });

    group('State management', () {
      test('should maintain state consistency across operations', () {
        // Arrange
        final exercise1 = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );
        final exercise2 = RoutineExercise(
          id: 'exercise-2',
          exerciseId: 'base-exercise-2',
          routineSectionId: 'section-1',
          order: 2,
        );

        // Act & Assert
        notifier.initializeExercise(exercise1);
        expect(notifier.state.length, equals(1));
        expect(notifier.getExercise('exercise-1'), equals(exercise1));

        notifier.initializeExercise(exercise2);
        expect(notifier.state.length, equals(2));
        expect(notifier.getExercise('exercise-2'), equals(exercise2));

        notifier.clearExerciseStates();
        expect(notifier.state, isEmpty);
        expect(notifier.getExercise('exercise-1'), isNull);
        expect(notifier.getExercise('exercise-2'), isNull);
      });

      test('should handle concurrent state modifications', () {
        // Arrange
        final exercise1 = RoutineExercise(
          id: 'exercise-1',
          exerciseId: 'base-exercise-1',
          routineSectionId: 'section-1',
          order: 1,
        );
        final exercise2 = RoutineExercise(
          id: 'exercise-2',
          exerciseId: 'base-exercise-2',
          routineSectionId: 'section-1',
          order: 2,
        );

        // Act - Simulate concurrent operations
        notifier.initializeExercise(exercise1);
        notifier.initializeExercise(exercise2);
        notifier.clearExerciseStates();
        notifier.initializeExercise(exercise1);

        // Assert
        expect(notifier.state.length, equals(1));
        expect(notifier.getExercise('exercise-1'), equals(exercise1));
        expect(notifier.getExercise('exercise-2'), isNull);
      });
    });
  });
}
