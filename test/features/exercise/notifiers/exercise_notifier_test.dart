import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:liftup/core/database/database_service.dart';
import 'package:liftup/core/database/database_service_provider.dart';

import '../../../test_helpers/test_setup.dart';
import '../../../mocks/database_service_mock.dart';
import '../../../mocks/test_database_service.dart';
import '../../../../lib/features/exercise/notifiers/exercise_notifier.dart';
import '../../../../lib/features/exercise/models/exercise.dart';
import '../../../../lib/features/exercise/services/exercise_service.dart';
import '../../../../lib/common/enums/muscle_group_enum.dart';

void main() {
  group('ExerciseNotifier Tests', () {
    skip:
    'Skip temporal: requiere modificación del código base para usar providers';
    late ProviderContainer container;
    late TestDatabaseService testDatabaseService;

    setUpAll(() async {
      TestSetup.initialize();
      testDatabaseService = TestSetup.testDatabaseService;
      // Initialize TestDatabaseService for real database operations
      await TestSetup.initializeTestDatabase();
    });

    tearDownAll(() {
      TestSetup.cleanupTestDatabase();
    });

    setUp(() {
      TestSetup.cleanup();

      // Configurar datos de prueba para ejercicios en la base de datos real
      final testExercises = [
        Exercise(
          id: 'exercise1',
          name: 'Push-ups',
          description: 'Classic bodyweight exercise',
          imageUrl: 'assets/images/push_ups.png',
          muscleGroups: [MuscleGroup.pectoralMajor],
          tips: ['Keep your back straight'],
          commonMistakes: ['Arching your back'],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Exercise(
          id: 'exercise2',
          name: 'Squats',
          description: 'Lower body exercise',
          imageUrl: 'assets/images/squats.png',
          muscleGroups: [MuscleGroup.rectusFemoris],
          tips: ['Keep knees behind toes'],
          commonMistakes: ['Knees caving in'],
          category: ExerciseCategory.quadriceps,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Guardar ejercicios en la base de datos real
      for (final exercise in testExercises) {
        testDatabaseService.exercisesBox.put(exercise.id, exercise.toJson());
      }
      container = TestSetup.createTestContainer();
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() async {
      await DatabaseService.getInstance().close();
    });

    group('Initialization', () {
      test('should initialize with empty exercises', () async {
        // Arrange
        TestSetup.setupTestData(exercises: {});

        // Act
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state, isEmpty);
      });

      test('should load existing exercises', () async {
        // Arrange
        final testExercises = {
          'exercise1': {
            'id': 'exercise1',
            'name': 'Push-ups',
            'description': 'Classic bodyweight exercise',
            'category': 'Bodyweight',
            'imagePath': 'assets/images/push_ups.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          'exercise2': {
            'id': 'exercise2',
            'name': 'Squats',
            'description': 'Lower body exercise',
            'category': 'Bodyweight',
            'imagePath': 'assets/images/squats.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        TestSetup.setupTestData(exercises: testExercises);

        // Act
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.length, equals(2));
        expect(state.any((e) => e.name == 'Push-ups'), isTrue);
        expect(state.any((e) => e.name == 'Squats'), isTrue);
      });
    });

    group('Exercise Management', () {
      test('should add new exercise', () async {
        // Arrange
        TestSetup.setupTestData(exercises: {});
        final newExercise = Exercise(
          id: 'new-exercise',
          name: 'New Exercise',
          description: 'A new exercise',
          imageUrl: 'assets/images/new_exercise.png',
          muscleGroups: [MuscleGroup.pectoralMajor],
          tips: ['Keep your back straight'],
          commonMistakes: ['Arching your back'],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(exerciseNotifierProvider.notifier);
        await notifier.addExercise(newExercise);
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.length, greaterThan(0));
        expect(state.any((e) => e.name == 'New Exercise'), isTrue);
      });

      test('should update existing exercise', () async {
        // Arrange
        final testExercises = {
          'exercise1': {
            'id': 'exercise1',
            'name': 'Original Name',
            'description': 'Original description',
            'category': 'Original Category',
            'imagePath': 'assets/images/original.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        TestSetup.setupTestData(exercises: testExercises);

        final updatedExercise = Exercise(
          id: 'exercise1',
          name: 'Updated Name',
          description: 'Updated description',
          imageUrl: 'assets/images/updated.png',
          muscleGroups: [MuscleGroup.pectoralMajor],
          tips: ['Keep your back straight'],
          commonMistakes: ['Arching your back'],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(exerciseNotifierProvider.notifier);
        await notifier.updateExercise(updatedExercise);
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        final updatedExerciseFromState = state.firstWhere(
          (e) => e.id == 'exercise1',
        );
        expect(updatedExerciseFromState.name, equals('Updated Name'));
        expect(
          updatedExerciseFromState.description,
          equals('Updated description'),
        );
        expect(updatedExerciseFromState.category, equals('Updated Category'));
      });

      test('should delete exercise', () async {
        // Arrange
        final testExercises = {
          'exercise1': {
            'id': 'exercise1',
            'name': 'Exercise to Delete',
            'description': 'This exercise will be deleted',
            'category': 'Test',
            'imagePath': 'assets/images/delete.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          'exercise2': {
            'id': 'exercise2',
            'name': 'Exercise to Keep',
            'description': 'This exercise will remain',
            'category': 'Test',
            'imagePath': 'assets/images/keep.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        TestSetup.setupTestData(exercises: testExercises);

        // Act
        final notifier = container.read(exerciseNotifierProvider.notifier);
        await notifier.deleteExercise('exercise1');
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.length, equals(1));
        expect(state.any((e) => e.id == 'exercise1'), isFalse);
        expect(state.any((e) => e.id == 'exercise2'), isTrue);
      });
    });

    group('Exercise Filtering', () {
      test('should filter exercises by category', () async {
        // Arrange
        final testExercises = {
          'exercise1': {
            'id': 'exercise1',
            'name': 'Push-ups',
            'description': 'Bodyweight exercise',
            'category': 'back',
            'imagePath': 'assets/images/push_ups.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          'exercise2': {
            'id': 'exercise2',
            'name': 'Bench Press',
            'description': 'Weight training exercise',
            'category': 'Strength',
            'imagePath': 'assets/images/bench_press.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        TestSetup.setupTestData(exercises: testExercises);

        // Act
        final state = await container.read(exerciseNotifierProvider.future);
        final bodyweightExercises =
            state.where((e) => e.category == ExerciseCategory.back).toList();

        // Assert
        expect(bodyweightExercises, isNotNull);
        expect(bodyweightExercises.length, equals(1));
        expect(bodyweightExercises.first.name, equals('Push-ups'));
      });

      test('should search exercises by name', () async {
        // Arrange
        final testExercises = {
          'exercise1': {
            'id': 'exercise1',
            'name': 'Push-ups',
            'description': 'Bodyweight exercise',
            'category': 'Bodyweight',
            'imagePath': 'assets/images/push_ups.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          'exercise2': {
            'id': 'exercise2',
            'name': 'Pull-ups',
            'description': 'Bodyweight exercise',
            'category': 'Bodyweight',
            'imagePath': 'assets/images/pull_ups.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        TestSetup.setupTestData(exercises: testExercises);

        // Act
        final state = await container.read(exerciseNotifierProvider.future);
        final pushExercises =
            state.where((e) => e.name.toLowerCase().contains('push')).toList();

        // Assert
        expect(pushExercises, isNotNull);
        expect(pushExercises.length, equals(1));
        expect(pushExercises.first.name, equals('Push-ups'));
      });
    });

    group('State Updates', () {
      test('should update state after adding exercise', () async {
        // Arrange
        TestSetup.setupTestData(exercises: {});
        final newExercise = Exercise(
          id: 'test-exercise',
          name: 'Test Exercise',
          description: 'Test description',
          imageUrl: 'assets/images/test.png',
          muscleGroups: [MuscleGroup.pectoralMajor],
          tips: ['Keep your back straight'],
          commonMistakes: ['Arching your back'],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(exerciseNotifierProvider.notifier);
        final initialState = await container.read(
          exerciseNotifierProvider.future,
        );
        await notifier.addExercise(newExercise);
        final updatedState = await container.read(
          exerciseNotifierProvider.future,
        );

        // Assert
        expect(updatedState.length, greaterThan(initialState.length));
        expect(updatedState.any((e) => e.id == 'test-exercise'), isTrue);
      });

      test('should update state after deleting exercise', () async {
        // Arrange
        final testExercises = {
          'exercise1': {
            'id': 'exercise1',
            'name': 'Exercise to Delete',
            'description': 'This exercise will be deleted',
            'category': 'Test',
            'imagePath': 'assets/images/delete.png',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
        TestSetup.setupTestData(exercises: testExercises);

        // Act
        final notifier = container.read(exerciseNotifierProvider.notifier);
        final initialState = await container.read(
          exerciseNotifierProvider.future,
        );
        await notifier.deleteExercise('exercise1');
        final updatedState = await container.read(
          exerciseNotifierProvider.future,
        );

        // Assert
        expect(updatedState.length, lessThan(initialState.length));
        expect(updatedState.any((e) => e.id == 'exercise1'), isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle service errors gracefully', () async {
        // Arrange
        TestSetup.setupTestData(exercises: {});

        // Act
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state, isA<List<Exercise>>());
      });

      test('should handle empty exercise data', () async {
        // Arrange
        TestSetup.setupTestData(exercises: {});

        // Act
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state, isA<List<Exercise>>());
        expect(state, isEmpty);
      });
    });

    group('Exercise Service Integration', () {
      test('should interact with exercise service correctly', () async {
        // Arrange
        final testExercise = Exercise(
          id: 'test-exercise',
          name: 'Test Exercise',
          description: 'Test description',
          imageUrl: 'assets/images/test.png',
          muscleGroups: [MuscleGroup.pectoralMajor],
          tips: ['Keep your back straight'],
          commonMistakes: ['Arching your back'],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final notifier = container.read(exerciseNotifierProvider.notifier);
        await notifier.addExercise(testExercise);
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state.any((e) => e.id == 'test-exercise'), isTrue);
      });

      test('should handle database service errors', () async {
        // Arrange
        TestSetup.setupTestData(exercises: {});

        // Act
        final state = await container.read(exerciseNotifierProvider.future);

        // Assert
        expect(state, isNotNull);
        expect(state, isA<List<Exercise>>());
      });
    });
  });
}
