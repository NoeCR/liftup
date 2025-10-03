import 'package:flutter_test/flutter_test.dart';
import 'package:liftup/features/exercise/models/exercise.dart';
import 'package:liftup/features/home/models/routine.dart';
import 'package:liftup/common/enums/muscle_group_enum.dart';
import 'package:liftup/common/enums/week_day_enum.dart';
import '../mocks/database_service_mock.dart';

void main() {
  group('Database Performance Tests', () {
    late MockDatabaseService mockDatabaseService;

    setUpAll(() async {
      // Initialize mock database service for testing
      mockDatabaseService = MockDatabaseService.getInstance();
      mockDatabaseService.setupMockBehavior();
      await mockDatabaseService.initialize();
    });

    tearDownAll(() async {
      await mockDatabaseService.close();
    });

    group('Exercise Operations Performance', () {
      test(
        'should handle large number of exercise operations efficiently',
        () async {
          final stopwatch = Stopwatch()..start();

          // Create multiple exercises
          final exercises = List.generate(
            100,
            (index) => Exercise(
              id: 'exercise_$index',
              name: 'Exercise $index',
              description: 'Description for exercise $index',
              imageUrl: 'assets/images/exercise_$index.png',
              muscleGroups: [MuscleGroup.pectoralMajor],
              tips: ['Tip $index'],
              commonMistakes: ['Mistake $index'],
              category: ExerciseCategory.chest,
              difficulty: ExerciseDifficulty.beginner,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          // Save all exercises
          for (final exercise in exercises) {
            await mockDatabaseService.exercisesBox.put(
              exercise.id,
              exercise.toJson(),
            );
          }

          stopwatch.stop();

          // Verify performance (should complete within reasonable time)
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(5000),
          ); // 5 seconds max

          // Clean up
          await mockDatabaseService.exercisesBox.clear();
        },
      );

      test('should handle exercise search efficiently', () async {
        // Create test data
        final exercises = List.generate(
          50,
          (index) => Exercise(
            id: 'exercise_$index',
            name: 'Exercise $index',
            description: 'Description for exercise $index',
            imageUrl: 'assets/images/exercise_$index.png',
            muscleGroups: [MuscleGroup.pectoralMajor],
            tips: ['Tip $index'],
            commonMistakes: ['Mistake $index'],
            category: ExerciseCategory.chest,
            difficulty: ExerciseDifficulty.beginner,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Save exercises
        for (final exercise in exercises) {
          await mockDatabaseService.exercisesBox.put(
            exercise.id,
            exercise.toJson(),
          );
        }

        final stopwatch = Stopwatch()..start();

        // Perform search operations
        final allExercises = mockDatabaseService.exercisesBox.values.toList();
        final filteredExercises =
            allExercises
                .where(
                  (exercise) =>
                      exercise['name'].toString().contains('Exercise'),
                )
                .toList();

        stopwatch.stop();

        // Verify performance
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 second max
        expect(filteredExercises.length, equals(50));

        // Clean up
        await mockDatabaseService.exercisesBox.clear();
      });
    });

    group('Routine Operations Performance', () {
      test('should handle routine operations efficiently', () async {
        final stopwatch = Stopwatch()..start();

        // Create multiple routines
        final routines = List.generate(
          20,
          (index) => Routine(
            id: 'routine_$index',
            name: 'Routine $index',
            description: 'Description for routine $index',
            days: [WeekDay.monday, WeekDay.wednesday, WeekDay.friday],
            sections: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Save all routines
        for (final routine in routines) {
          await mockDatabaseService.routinesBox.put(
            routine.id,
            routine.toJson(),
          );
        }

        stopwatch.stop();

        // Verify performance
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // 2 seconds max

        // Clean up
        await mockDatabaseService.routinesBox.clear();
      });
    });

    group('Concurrent Operations Performance', () {
      test('should handle concurrent read operations efficiently', () async {
        // Create test data
        final exercises = List.generate(
          10,
          (index) => Exercise(
            id: 'exercise_$index',
            name: 'Exercise $index',
            description: 'Description for exercise $index',
            imageUrl: 'assets/images/exercise_$index.png',
            muscleGroups: [MuscleGroup.pectoralMajor],
            tips: ['Tip $index'],
            commonMistakes: ['Mistake $index'],
            category: ExerciseCategory.chest,
            difficulty: ExerciseDifficulty.beginner,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Save exercises
        for (final exercise in exercises) {
          await mockDatabaseService.exercisesBox.put(
            exercise.id,
            exercise.toJson(),
          );
        }

        final stopwatch = Stopwatch()..start();

        // Perform concurrent read operations
        final futures = List.generate(10, (index) async {
          return mockDatabaseService.exercisesBox.get('exercise_$index');
        });

        await Future.wait(futures);

        stopwatch.stop();

        // Verify performance
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 second max

        // Clean up
        await mockDatabaseService.exercisesBox.clear();
      });
    });
  });
}
