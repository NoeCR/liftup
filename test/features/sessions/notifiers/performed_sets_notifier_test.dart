import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers/test_setup.dart';
import '../../../mocks/database_service_mock.dart';
import '../../../mocks/logging_service_mock.dart';
import '../../../../lib/features/sessions/notifiers/performed_sets_notifier.dart';

void main() {
  group('PerformedSetsNotifier Tests', () {
    late ProviderContainer container;
    late MockDatabaseService mockDatabaseService;
    late MockLoggingService mockLoggingService;

    setUpAll(() {
      TestSetup.initialize();
      mockDatabaseService = TestSetup.mockDatabaseService;
      mockLoggingService = TestSetup.mockLoggingService;
    });

    setUp(() {
      TestSetup.cleanup();
      container = TestSetup.createTestContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initialization', () {
      test('should initialize with empty state', () {
        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        final state = container.read(performedSetsNotifierProvider);

        // Assert
        expect(state, isNotNull);
        expect(state, isEmpty);
      });
    });

    group('Set Count Management', () {
      test('should set count for routine exercise', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const count = 3;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, count);
        final state = container.read(performedSetsNotifierProvider);

        // Assert
        expect(state[routineExerciseId], equals(count));
      });

      test('should get count for routine exercise', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const count = 5;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, count);
        final retrievedCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(retrievedCount, equals(count));
      });

      test('should return 0 for non-existent routine exercise', () {
        // Arrange
        const nonExistentId = 'non-existent';

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        final count = notifier.getCount(nonExistentId);

        // Assert
        expect(count, equals(0));
      });

      test('should increment count', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const initialCount = 2;
        const maxSets = 5;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, initialCount);
        notifier.increment(routineExerciseId, maxSets);
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(initialCount + 1));
      });

      test('should not increment beyond max sets', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const maxSets = 3;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, maxSets);
        notifier.increment(routineExerciseId, maxSets);
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(maxSets));
      });

      test('should decrement count', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const initialCount = 3;
        const maxSets = 5;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, initialCount);
        notifier.decrement(routineExerciseId, maxSets);
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(initialCount - 1));
      });

      test('should not decrement below 0', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const maxSets = 5;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, 0);
        notifier.decrement(routineExerciseId, maxSets);
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(0));
      });
    });

    group('State Management', () {
      test('should update state when count changes', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const count = 4;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        final initialState = container.read(performedSetsNotifierProvider);
        notifier.setCount(routineExerciseId, count);
        final updatedState = container.read(performedSetsNotifierProvider);

        // Assert
        expect(initialState, isEmpty);
        expect(updatedState[routineExerciseId], equals(count));
      });

      test('should maintain multiple routine exercises', () {
        // Arrange
        const routineExerciseId1 = 'routine-exercise-1';
        const routineExerciseId2 = 'routine-exercise-2';
        const count1 = 2;
        const count2 = 4;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId1, count1);
        notifier.setCount(routineExerciseId2, count2);
        final state = container.read(performedSetsNotifierProvider);

        // Assert
        expect(state[routineExerciseId1], equals(count1));
        expect(state[routineExerciseId2], equals(count2));
        expect(state.length, equals(2));
      });

      test('should clear all counts', () {
        // Arrange
        const routineExerciseId1 = 'routine-exercise-1';
        const routineExerciseId2 = 'routine-exercise-2';
        const count1 = 2;
        const count2 = 4;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId1, count1);
        notifier.setCount(routineExerciseId2, count2);
        notifier.clearAll();
        final state = container.read(performedSetsNotifierProvider);

        // Assert
        expect(state, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle negative count gracefully', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const negativeCount = -1;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, negativeCount);
        final count = notifier.getCount(routineExerciseId);

        // Assert
        expect(count, equals(negativeCount));
      });

      test('should handle zero count', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const zeroCount = 0;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, zeroCount);
        final count = notifier.getCount(routineExerciseId);

        // Assert
        expect(count, equals(zeroCount));
      });

      test('should handle large count values', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const largeCount = 1000;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, largeCount);
        final count = notifier.getCount(routineExerciseId);

        // Assert
        expect(count, equals(largeCount));
      });

      test('should handle empty routine exercise id', () {
        // Arrange
        const emptyId = '';
        const count = 3;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(emptyId, count);
        final retrievedCount = notifier.getCount(emptyId);

        // Assert
        expect(retrievedCount, equals(count));
      });
    });

    group('Increment/Decrement Logic', () {
      test('should increment multiple times correctly', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const maxSets = 10;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, 0);
        notifier.increment(routineExerciseId, maxSets);
        notifier.increment(routineExerciseId, maxSets);
        notifier.increment(routineExerciseId, maxSets);
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(3));
      });

      test('should decrement multiple times correctly', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const maxSets = 10;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, 5);
        notifier.decrement(routineExerciseId, maxSets);
        notifier.decrement(routineExerciseId, maxSets);
        notifier.decrement(routineExerciseId, maxSets);
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(2));
      });

      test('should respect max sets limit during increment', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';
        const maxSets = 3;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        notifier.setCount(routineExerciseId, maxSets - 1);
        notifier.increment(routineExerciseId, maxSets);
        notifier.increment(routineExerciseId, maxSets); // Should not increment
        final finalCount = notifier.getCount(routineExerciseId);

        // Assert
        expect(finalCount, equals(maxSets));
      });
    });

    group('State Persistence', () {
      test('should maintain state across multiple operations', () {
        // Arrange
        const routineExerciseId1 = 'routine-exercise-1';
        const routineExerciseId2 = 'routine-exercise-2';
        const maxSets = 5;

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        
        // Set initial counts
        notifier.setCount(routineExerciseId1, 2);
        notifier.setCount(routineExerciseId2, 3);
        
        // Perform operations
        notifier.increment(routineExerciseId1, maxSets);
        notifier.decrement(routineExerciseId2, maxSets);
        
        final state = container.read(performedSetsNotifierProvider);

        // Assert
        expect(state[routineExerciseId1], equals(3));
        expect(state[routineExerciseId2], equals(2));
        expect(state.length, equals(2));
      });

      test('should handle state updates correctly', () {
        // Arrange
        const routineExerciseId = 'routine-exercise-1';

        // Act
        final notifier = container.read(performedSetsNotifierProvider.notifier);
        final state1 = container.read(performedSetsNotifierProvider);
        
        notifier.setCount(routineExerciseId, 1);
        final state2 = container.read(performedSetsNotifierProvider);
        
        notifier.setCount(routineExerciseId, 2);
        final state3 = container.read(performedSetsNotifierProvider);

        // Assert
        expect(state1, isEmpty);
        expect(state2[routineExerciseId], equals(1));
        expect(state3[routineExerciseId], equals(2));
      });
    });
  });
}
