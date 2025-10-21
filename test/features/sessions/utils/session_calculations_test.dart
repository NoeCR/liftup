import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise_set.dart';
import 'package:liftly/features/sessions/utils/session_calculations.dart';

void main() {
  group('SessionCalculations', () {
    group('calculateTotalWeight', () {
      test('should return zero for empty list', () {
        // Act
        final result = SessionCalculations.calculateTotalWeight([]);

        // Assert
        expect(result, equals(0.0));
      });

      test('should return maximum weight for single set', () {
        // Arrange
        final sets = [
          ExerciseSet(
            id: 'set-1',
            exerciseId: 'exercise-1',
            weight: 60.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateTotalWeight(sets);

        // Assert
        expect(result, equals(60.0)); // Maximum weight used
      });

      test('should return maximum weight for multiple sets', () {
        // Arrange
        final sets = [
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
            weight: 65.0,
            reps: 8,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
          ExerciseSet(
            id: 'set-3',
            exerciseId: 'exercise-1',
            weight: 70.0,
            reps: 6,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateTotalWeight(sets);

        // Assert
        expect(result, equals(70.0)); // Maximum weight used (70.0)
      });

      test('should handle zero weight and reps', () {
        // Arrange
        final sets = [
          ExerciseSet(
            id: 'set-1',
            exerciseId: 'exercise-1',
            weight: 0.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
          ExerciseSet(
            id: 'set-2',
            exerciseId: 'exercise-1',
            weight: 60.0,
            reps: 0,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateTotalWeight(sets);

        // Assert
        expect(result, equals(60.0)); // Maximum weight used (60.0)
      });
    });

    group('calculateTotalReps', () {
      test('should return zero for empty list', () {
        // Act
        final result = SessionCalculations.calculateTotalReps([]);

        // Assert
        expect(result, equals(0));
      });

      test('should calculate total reps for single set', () {
        // Arrange
        final sets = [
          ExerciseSet(
            id: 'set-1',
            exerciseId: 'exercise-1',
            weight: 60.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateTotalReps(sets);

        // Assert
        expect(result, equals(10));
      });

      test('should calculate total reps for multiple sets', () {
        // Arrange
        final sets = [
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
            weight: 65.0,
            reps: 8,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
          ExerciseSet(
            id: 'set-3',
            exerciseId: 'exercise-1',
            weight: 70.0,
            reps: 6,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateTotalReps(sets);

        // Assert
        expect(result, equals(24)); // 10 + 8 + 6
      });
    });

    group('calculateTotalSets', () {
      test('should return zero for empty list', () {
        // Act
        final result = SessionCalculations.calculateTotalSets([]);

        // Assert
        expect(result, equals(0));
      });

      test('should return correct count for single set', () {
        // Arrange
        final sets = [
          ExerciseSet(
            id: 'set-1',
            exerciseId: 'exercise-1',
            weight: 60.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateTotalSets(sets);

        // Assert
        expect(result, equals(1));
      });

      test('should return correct count for multiple sets', () {
        // Arrange
        final sets = List.generate(
          5,
          (index) => ExerciseSet(
            id: 'set-$index',
            exerciseId: 'exercise-1',
            weight: 60.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        );

        // Act
        final result = SessionCalculations.calculateTotalSets(sets);

        // Assert
        expect(result, equals(5));
      });
    });

    group('calculateAverageWeightPerRep', () {
      test('should return zero for empty list', () {
        // Act
        final result = SessionCalculations.calculateAverageWeightPerRep([]);

        // Assert
        expect(result, equals(0.0));
      });

      test('should calculate average weight per rep correctly', () {
        // Arrange
        final sets = [
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
            weight: 80.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateAverageWeightPerRep(sets);

        // Assert
        expect(result, equals(70.0)); // (600 + 800) / (10 + 10) = 1400 / 20 = 70
      });

      test('should handle zero reps', () {
        // Arrange
        final sets = [
          ExerciseSet(
            id: 'set-1',
            exerciseId: 'exercise-1',
            weight: 60.0,
            reps: 0,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateAverageWeightPerRep(sets);

        // Assert
        expect(result, equals(0.0));
      });
    });

    group('calculateAverageRepsPerSet', () {
      test('should return zero for empty list', () {
        // Act
        final result = SessionCalculations.calculateAverageRepsPerSet([]);

        // Assert
        expect(result, equals(0.0));
      });

      test('should calculate average reps per set correctly', () {
        // Arrange
        final sets = [
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
            weight: 65.0,
            reps: 8,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
          ExerciseSet(
            id: 'set-3',
            exerciseId: 'exercise-1',
            weight: 70.0,
            reps: 6,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateAverageRepsPerSet(sets);

        // Assert
        expect(result, equals(8.0)); // (10 + 8 + 6) / 3
      });
    });

    group('calculateAverageWeightPerSet', () {
      test('should return zero for empty list', () {
        // Act
        final result = SessionCalculations.calculateAverageWeightPerSet([]);

        // Assert
        expect(result, equals(0.0));
      });

      test('should calculate average weight per set correctly', () {
        // Arrange
        final sets = [
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
            weight: 80.0,
            reps: 10,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateAverageWeightPerSet(sets);

        // Assert
        expect(result, equals(700.0)); // (600 + 800) / 2
      });
    });

    group('calculateExerciseTotals', () {
      test('should return empty map for empty list', () {
        // Act
        final result = SessionCalculations.calculateExerciseTotals([]);

        // Assert
        expect(result, isEmpty);
      });

      test('should calculate totals for single exercise', () {
        // Arrange
        final sets = [
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
            weight: 65.0,
            reps: 8,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateExerciseTotals(sets);

        // Assert
        expect(result.length, equals(1));
        expect(result.containsKey('exercise-1'), isTrue);

        final totals = result['exercise-1']!;
        expect(totals.totalWeight, equals(65.0)); // Maximum weight used (65.0)
        expect(totals.totalReps, equals(18)); // 10 + 8
        expect(totals.totalSets, equals(2));
        expect(totals.averageWeightPerRep, equals(1120.0 / 18)); // Still uses total weight lifted for average
        expect(totals.averageRepsPerSet, equals(9.0)); // 18 / 2
        expect(totals.averageWeightPerSet, equals(560.0)); // 1120 / 2
      });

      test('should calculate totals for multiple exercises', () {
        // Arrange
        final sets = [
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
            exerciseId: 'exercise-2',
            weight: 30.0,
            reps: 15,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
          ExerciseSet(
            id: 'set-3',
            exerciseId: 'exercise-1',
            weight: 65.0,
            reps: 8,
            completedAt: DateTime.now(),
            isCompleted: true,
          ),
        ];

        // Act
        final result = SessionCalculations.calculateExerciseTotals(sets);

        // Assert
        expect(result.length, equals(2));
        expect(result.containsKey('exercise-1'), isTrue);
        expect(result.containsKey('exercise-2'), isTrue);

        final exercise1Totals = result['exercise-1']!;
        expect(exercise1Totals.totalWeight, equals(65.0)); // Maximum weight used (65.0)
        expect(exercise1Totals.totalReps, equals(18)); // 10 + 8
        expect(exercise1Totals.totalSets, equals(2));

        final exercise2Totals = result['exercise-2']!;
        expect(exercise2Totals.totalWeight, equals(30.0)); // Maximum weight used (30.0)
        expect(exercise2Totals.totalReps, equals(15));
        expect(exercise2Totals.totalSets, equals(1));
      });
    });
  });

  group('ExerciseTotals', () {
    test('should create ExerciseTotals with correct values', () {
      // Act
      const totals = ExerciseTotals(
        totalWeight: 1000.0,
        totalReps: 50,
        totalSets: 5,
        averageWeightPerRep: 20.0,
        averageRepsPerSet: 10.0,
        averageWeightPerSet: 200.0,
      );

      // Assert
      expect(totals.totalWeight, equals(1000.0));
      expect(totals.totalReps, equals(50));
      expect(totals.totalSets, equals(5));
      expect(totals.averageWeightPerRep, equals(20.0));
      expect(totals.averageRepsPerSet, equals(10.0));
      expect(totals.averageWeightPerSet, equals(200.0));
    });

    test('should format toString correctly', () {
      // Arrange
      const totals = ExerciseTotals(
        totalWeight: 1000.0,
        totalReps: 50,
        totalSets: 5,
        averageWeightPerRep: 20.123456,
        averageRepsPerSet: 10.987654,
        averageWeightPerSet: 200.555555,
      );

      // Act
      final result = totals.toString();

      // Assert
      expect(result, contains('totalWeight: 1000.0'));
      expect(result, contains('totalReps: 50'));
      expect(result, contains('totalSets: 5'));
      expect(result, contains('avgWeightPerRep: 20.12'));
      expect(result, contains('avgRepsPerSet: 10.99'));
      expect(result, contains('avgWeightPerSet: 200.56'));
    });
  });
}
