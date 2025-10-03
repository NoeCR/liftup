import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftup/features/sessions/notifiers/performed_sets_notifier.dart';

void main() {
  group('PerformedSetsNotifier Tests', () {
    late ProviderContainer container;
    late PerformedSetsNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(performedSetsNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initialization', () {
      test('should initialize with empty state', () {
        expect(notifier.state, isEmpty);
      });

      test('should provide correct initial state through provider', () {
        final state = container.read(performedSetsNotifierProvider);
        expect(state, isEmpty);
      });
    });

    group('Count Management', () {
      test('should get count for existing routine exercise', () {
        const routineExerciseId = 'routine_exercise_1';
        const count = 3;
        
        notifier.setCount(routineExerciseId, count);
        
        expect(notifier.getCount(routineExerciseId), equals(count));
      });

      test('should return 0 for non-existing routine exercise', () {
        const routineExerciseId = 'non_existing';
        
        expect(notifier.getCount(routineExerciseId), equals(0));
      });

      test('should set count for routine exercise', () {
        const routineExerciseId = 'routine_exercise_1';
        const count = 5;
        
        notifier.setCount(routineExerciseId, count);
        
        expect(notifier.state[routineExerciseId], equals(count));
      });

      test('should update count for existing routine exercise', () {
        const routineExerciseId = 'routine_exercise_1';
        
        notifier.setCount(routineExerciseId, 3);
        notifier.setCount(routineExerciseId, 7);
        
        expect(notifier.getCount(routineExerciseId), equals(7));
      });
    });

    group('Increment Operations', () {
      test('should increment count when below max sets', () {
        const routineExerciseId = 'routine_exercise_1';
        const maxSets = 5;
        
        notifier.setCount(routineExerciseId, 2);
        notifier.increment(routineExerciseId, maxSets);
        
        expect(notifier.getCount(routineExerciseId), equals(3));
      });

      test('should not increment when at max sets', () {
        const routineExerciseId = 'routine_exercise_1';
        const maxSets = 5;
        
        notifier.setCount(routineExerciseId, maxSets);
        notifier.increment(routineExerciseId, maxSets);
        
        expect(notifier.getCount(routineExerciseId), equals(maxSets));
      });

      test('should increment from 0 when below max sets', () {
        const routineExerciseId = 'routine_exercise_1';
        const maxSets = 3;
        
        notifier.increment(routineExerciseId, maxSets);
        
        expect(notifier.getCount(routineExerciseId), equals(1));
      });
    });

    group('Decrement Operations', () {
      test('should decrement count when above 0', () {
        const routineExerciseId = 'routine_exercise_1';
        const maxSets = 5;
        
        notifier.setCount(routineExerciseId, 3);
        notifier.decrement(routineExerciseId, maxSets);
        
        expect(notifier.getCount(routineExerciseId), equals(2));
      });

      test('should not decrement when at 0', () {
        const routineExerciseId = 'routine_exercise_1';
        const maxSets = 5;
        
        notifier.setCount(routineExerciseId, 0);
        notifier.decrement(routineExerciseId, maxSets);
        
        expect(notifier.getCount(routineExerciseId), equals(0));
      });

      test('should not decrement for non-existing routine exercise', () {
        const routineExerciseId = 'non_existing';
        const maxSets = 5;
        
        notifier.decrement(routineExerciseId, maxSets);
        
        expect(notifier.getCount(routineExerciseId), equals(0));
      });
    });

    group('Clear Operations', () {
      test('should clear all counts', () {
        notifier.setCount('routine_exercise_1', 3);
        notifier.setCount('routine_exercise_2', 5);
        notifier.setCount('routine_exercise_3', 2);
        
        notifier.clearAll();
        
        expect(notifier.state, isEmpty);
      });

      test('should clear empty state without error', () {
        notifier.clearAll();
        
        expect(notifier.state, isEmpty);
      });
    });

    group('Multiple Routine Exercises', () {
      test('should handle multiple routine exercises independently', () {
        notifier.setCount('routine_exercise_1', 3);
        notifier.setCount('routine_exercise_2', 5);
        notifier.setCount('routine_exercise_3', 2);
        
        expect(notifier.getCount('routine_exercise_1'), equals(3));
        expect(notifier.getCount('routine_exercise_2'), equals(5));
        expect(notifier.getCount('routine_exercise_3'), equals(2));
      });

      test('should update one routine exercise without affecting others', () {
        notifier.setCount('routine_exercise_1', 3);
        notifier.setCount('routine_exercise_2', 5);
        
        notifier.setCount('routine_exercise_1', 7);
        
        expect(notifier.getCount('routine_exercise_1'), equals(7));
        expect(notifier.getCount('routine_exercise_2'), equals(5));
      });
    });

    group('State Management', () {
      test('should maintain state consistency', () {
        const routineExerciseId = 'routine_exercise_1';
        
        notifier.setCount(routineExerciseId, 3);
        notifier.increment(routineExerciseId, 10);
        notifier.decrement(routineExerciseId, 10);
        
        expect(notifier.getCount(routineExerciseId), equals(3));
      });

      test('should notify listeners on state changes', () {
        var listenerCallCount = 0;
        
        container.listen(
          performedSetsNotifierProvider,
          (previous, next) {
            listenerCallCount++;
          },
        );
        
        notifier.setCount('routine_exercise_1', 3);
        notifier.increment('routine_exercise_1', 10);
        notifier.clearAll();
        
        expect(listenerCallCount, equals(3));
      });
    });
  });
}