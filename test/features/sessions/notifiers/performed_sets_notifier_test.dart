import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/sessions/notifiers/performed_sets_notifier.dart';

void main() {
  group('PerformedSetsNotifier', () {
    late PerformedSetsNotifier notifier;

    setUp(() {
      notifier = PerformedSetsNotifier();
    });

    group('getCount', () {
      test('should return zero for non-existent exercise', () {
        // Act
        final result = notifier.getCount('non-existent');

        // Assert
        expect(result, equals(0));
      });

      test('should return correct count for existing exercise', () {
        // Arrange
        notifier.setCount('exercise-1', 3);

        // Act
        final result = notifier.getCount('exercise-1');

        // Assert
        expect(result, equals(3));
      });

      test('should return zero for exercise with zero count', () {
        // Arrange
        notifier.setCount('exercise-1', 0);

        // Act
        final result = notifier.getCount('exercise-1');

        // Assert
        expect(result, equals(0));
      });
    });

    group('setCount', () {
      test('should set count for new exercise', () {
        // Act
        notifier.setCount('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(5));
        expect(notifier.state['exercise-1'], equals(5));
      });

      test('should update count for existing exercise', () {
        // Arrange
        notifier.setCount('exercise-1', 3);

        // Act
        notifier.setCount('exercise-1', 7);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(7));
        expect(notifier.state['exercise-1'], equals(7));
      });

      test('should set count to zero', () {
        // Arrange
        notifier.setCount('exercise-1', 5);

        // Act
        notifier.setCount('exercise-1', 0);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(0));
        expect(notifier.state['exercise-1'], equals(0));
      });

      test('should handle multiple exercises independently', () {
        // Act
        notifier.setCount('exercise-1', 3);
        notifier.setCount('exercise-2', 5);
        notifier.setCount('exercise-3', 2);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(3));
        expect(notifier.getCount('exercise-2'), equals(5));
        expect(notifier.getCount('exercise-3'), equals(2));
        expect(notifier.state.length, equals(3));
      });
    });

    group('increment', () {
      test('should increment count when below max sets', () {
        // Arrange
        notifier.setCount('exercise-1', 2);

        // Act
        notifier.increment('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(3));
      });

      test('should not increment when at max sets', () {
        // Arrange
        notifier.setCount('exercise-1', 5);

        // Act
        notifier.increment('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(5));
      });

      test('should increment from zero when max sets > 0', () {
        // Act
        notifier.increment('exercise-1', 3);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(1));
      });

      test('should not increment when max sets is zero', () {
        // Act
        notifier.increment('exercise-1', 0);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(0));
      });

      test('should handle multiple increments', () {
        // Act
        notifier.increment('exercise-1', 5);
        notifier.increment('exercise-1', 5);
        notifier.increment('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(3));
      });

      test('should stop incrementing at max sets', () {
        // Act
        notifier.increment('exercise-1', 3);
        notifier.increment('exercise-1', 3);
        notifier.increment('exercise-1', 3);
        notifier.increment('exercise-1', 3); // This should not increment

        // Assert
        expect(notifier.getCount('exercise-1'), equals(3));
      });
    });

    group('decrement', () {
      test('should decrement count when above zero', () {
        // Arrange
        notifier.setCount('exercise-1', 3);

        // Act
        notifier.decrement('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(2));
      });

      test('should not decrement when at zero', () {
        // Arrange
        notifier.setCount('exercise-1', 0);

        // Act
        notifier.decrement('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(0));
      });

      test('should not decrement for non-existent exercise', () {
        // Act
        notifier.decrement('non-existent', 5);

        // Assert
        expect(notifier.getCount('non-existent'), equals(0));
      });

      test('should handle multiple decrements', () {
        // Arrange
        notifier.setCount('exercise-1', 5);

        // Act
        notifier.decrement('exercise-1', 5);
        notifier.decrement('exercise-1', 5);
        notifier.decrement('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(2));
      });

      test('should stop decrementing at zero', () {
        // Arrange
        notifier.setCount('exercise-1', 2);

        // Act
        notifier.decrement('exercise-1', 5);
        notifier.decrement('exercise-1', 5);
        notifier.decrement('exercise-1', 5); // This should not decrement

        // Assert
        expect(notifier.getCount('exercise-1'), equals(0));
      });
    });

    group('clearAll', () {
      test('should clear all exercise counts', () {
        // Arrange
        notifier.setCount('exercise-1', 3);
        notifier.setCount('exercise-2', 5);
        notifier.setCount('exercise-3', 2);
        expect(notifier.state.length, equals(3));

        // Act
        notifier.clearAll();

        // Assert
        expect(notifier.state, isEmpty);
        expect(notifier.getCount('exercise-1'), equals(0));
        expect(notifier.getCount('exercise-2'), equals(0));
        expect(notifier.getCount('exercise-3'), equals(0));
      });

      test('should clear empty state without error', () {
        // Act
        notifier.clearAll();

        // Assert
        expect(notifier.state, isEmpty);
      });

      test('should allow setting counts after clearing', () {
        // Arrange
        notifier.setCount('exercise-1', 3);
        notifier.clearAll();

        // Act
        notifier.setCount('exercise-1', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(5));
        expect(notifier.state.length, equals(1));
      });
    });

    group('State management', () {
      test('should maintain state consistency across operations', () {
        // Act & Assert
        expect(notifier.getCount('exercise-1'), equals(0));

        notifier.setCount('exercise-1', 3);
        expect(notifier.getCount('exercise-1'), equals(3));

        notifier.increment('exercise-1', 5);
        expect(notifier.getCount('exercise-1'), equals(4));

        notifier.decrement('exercise-1', 5);
        expect(notifier.getCount('exercise-1'), equals(3));

        notifier.clearAll();
        expect(notifier.getCount('exercise-1'), equals(0));
      });

      test('should handle multiple exercises independently', () {
        // Act
        notifier.setCount('exercise-1', 2);
        notifier.setCount('exercise-2', 4);
        notifier.increment('exercise-1', 5);
        notifier.decrement('exercise-2', 5);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(3));
        expect(notifier.getCount('exercise-2'), equals(3));
        expect(notifier.state.length, equals(2));
      });

      test('should handle rapid state changes', () {
        // Act - Rapid increments and decrements
        for (int i = 0; i < 10; i++) {
          notifier.increment('exercise-1', 5);
        }
        expect(notifier.getCount('exercise-1'), equals(5));

        for (int i = 0; i < 10; i++) {
          notifier.decrement('exercise-1', 5);
        }
        expect(notifier.getCount('exercise-1'), equals(0));
      });
    });

    group('Edge cases', () {
      test('should handle negative max sets gracefully', () {
        // Act
        notifier.increment('exercise-1', -1);
        notifier.decrement('exercise-1', -1);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(0));
      });

      test('should handle very large counts', () {
        // Act
        notifier.setCount('exercise-1', 1000);
        notifier.increment('exercise-1', 1001);

        // Assert
        expect(notifier.getCount('exercise-1'), equals(1001));
      });

      test('should handle empty string exercise IDs', () {
        // Act
        notifier.setCount('', 3);
        notifier.increment('', 5);
        notifier.decrement('', 5);

        // Assert
        expect(notifier.getCount(''), equals(3)); // 3 + 1 - 1 = 3
      });
    });
  });
}
