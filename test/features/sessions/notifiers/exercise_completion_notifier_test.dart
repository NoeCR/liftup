import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/sessions/notifiers/exercise_completion_notifier.dart';

void main() {
  group('ExerciseCompletionNotifier', () {
    late ProviderContainer container;
    late ExerciseCompletionNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(exerciseCompletionNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('toggleExerciseCompletion', () {
      test('should add exercise to completed set when not present', () {
        // Act
        notifier.toggleExerciseCompletion('exercise-1');

        // Assert
        expect(notifier.state.contains('exercise-1'), isTrue);
        expect(notifier.completedCount, equals(1));
      });

      test('should remove exercise from completed set when present', () {
        // Arrange
        notifier.toggleExerciseCompletion('exercise-1');
        expect(notifier.state.contains('exercise-1'), isTrue);

        // Act
        notifier.toggleExerciseCompletion('exercise-1');

        // Assert
        expect(notifier.state.contains('exercise-1'), isFalse);
        expect(notifier.completedCount, equals(0));
      });

      test('should handle multiple exercises independently', () {
        // Act
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-2');
        notifier.toggleExerciseCompletion('exercise-3');

        // Assert
        expect(notifier.state.contains('exercise-1'), isTrue);
        expect(notifier.state.contains('exercise-2'), isTrue);
        expect(notifier.state.contains('exercise-3'), isTrue);
        expect(notifier.completedCount, equals(3));

        // Toggle one off
        notifier.toggleExerciseCompletion('exercise-2');

        // Assert
        expect(notifier.state.contains('exercise-1'), isTrue);
        expect(notifier.state.contains('exercise-2'), isFalse);
        expect(notifier.state.contains('exercise-3'), isTrue);
        expect(notifier.completedCount, equals(2));
      });

      test('should handle toggling same exercise multiple times', () {
        // Act
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-1');

        // Assert
        expect(notifier.state.contains('exercise-1'), isTrue);
        expect(notifier.completedCount, equals(1));
      });
    });

    group('isExerciseCompleted', () {
      test('should return true when exercise is completed', () {
        // Arrange
        notifier.toggleExerciseCompletion('exercise-1');

        // Act
        final result = notifier.isExerciseCompleted('exercise-1');

        // Assert
        expect(result, isTrue);
      });

      test('should return false when exercise is not completed', () {
        // Act
        final result = notifier.isExerciseCompleted('exercise-1');

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exercise was completed then toggled off', () {
        // Arrange
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-1');

        // Act
        final result = notifier.isExerciseCompleted('exercise-1');

        // Assert
        expect(result, isFalse);
      });
    });

    group('clearCompletedExercises', () {
      test('should clear all completed exercises', () {
        // Arrange
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-2');
        notifier.toggleExerciseCompletion('exercise-3');
        expect(notifier.completedCount, equals(3));

        // Act
        notifier.clearCompletedExercises();

        // Assert
        expect(notifier.state, isEmpty);
        expect(notifier.completedCount, equals(0));
        expect(notifier.isExerciseCompleted('exercise-1'), isFalse);
        expect(notifier.isExerciseCompleted('exercise-2'), isFalse);
        expect(notifier.isExerciseCompleted('exercise-3'), isFalse);
      });

      test('should clear empty state without error', () {
        // Act
        notifier.clearCompletedExercises();

        // Assert
        expect(notifier.state, isEmpty);
        expect(notifier.completedCount, equals(0));
      });
    });

    group('completedCount', () {
      test('should return correct count for single exercise', () {
        // Act
        notifier.toggleExerciseCompletion('exercise-1');

        // Assert
        expect(notifier.completedCount, equals(1));
      });

      test('should return correct count for multiple exercises', () {
        // Act
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-2');
        notifier.toggleExerciseCompletion('exercise-3');

        // Assert
        expect(notifier.completedCount, equals(3));
      });

      test('should return zero when no exercises completed', () {
        // Assert
        expect(notifier.completedCount, equals(0));
      });

      test('should return zero after clearing', () {
        // Arrange
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-2');
        expect(notifier.completedCount, equals(2));

        // Act
        notifier.clearCompletedExercises();

        // Assert
        expect(notifier.completedCount, equals(0));
      });

      test('should update count when exercises are toggled off', () {
        // Arrange
        notifier.toggleExerciseCompletion('exercise-1');
        notifier.toggleExerciseCompletion('exercise-2');
        notifier.toggleExerciseCompletion('exercise-3');
        expect(notifier.completedCount, equals(3));

        // Act
        notifier.toggleExerciseCompletion('exercise-2');

        // Assert
        expect(notifier.completedCount, equals(2));
      });
    });

    group('State consistency', () {
      test('should maintain state consistency across operations', () {
        // Act & Assert
        expect(notifier.completedCount, equals(0));
        expect(notifier.isExerciseCompleted('exercise-1'), isFalse);

        notifier.toggleExerciseCompletion('exercise-1');
        expect(notifier.completedCount, equals(1));
        expect(notifier.isExerciseCompleted('exercise-1'), isTrue);

        notifier.toggleExerciseCompletion('exercise-2');
        expect(notifier.completedCount, equals(2));
        expect(notifier.isExerciseCompleted('exercise-2'), isTrue);

        notifier.toggleExerciseCompletion('exercise-1');
        expect(notifier.completedCount, equals(1));
        expect(notifier.isExerciseCompleted('exercise-1'), isFalse);
        expect(notifier.isExerciseCompleted('exercise-2'), isTrue);

        notifier.clearCompletedExercises();
        expect(notifier.completedCount, equals(0));
        expect(notifier.isExerciseCompleted('exercise-1'), isFalse);
        expect(notifier.isExerciseCompleted('exercise-2'), isFalse);
      });

      test('should handle rapid state changes', () {
        // Act - Rapid toggling (9 times - odd number)
        for (int i = 0; i < 9; i++) {
          notifier.toggleExerciseCompletion('exercise-1');
        }

        // Assert - Should be completed (odd number of toggles)
        expect(notifier.isExerciseCompleted('exercise-1'), isTrue);
        expect(notifier.completedCount, equals(1));

        // Act - One more toggle
        notifier.toggleExerciseCompletion('exercise-1');

        // Assert - Should not be completed (even number of toggles)
        expect(notifier.isExerciseCompleted('exercise-1'), isFalse);
        expect(notifier.completedCount, equals(0));
      });
    });
  });
}
