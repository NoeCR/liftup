import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/home/notifiers/routine_exercise_notifier.dart';

void main() {
  group('RoutineExerciseNotifier Tests', () {
    late RoutineExerciseNotifier notifier;

    setUp(() {
      notifier = RoutineExerciseNotifier();
    });

    test('initial state should be empty', () {
      expect(notifier.state, isEmpty);
    });

    test('addExercisesToSection should add exercises to section', () {
      final sectionId = 'section1';
      final exercises = [
        Exercise(
          id: 'exercise1',
          name: 'Test Exercise 1',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Exercise(
          id: 'exercise2',
          name: 'Test Exercise 2',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      notifier.addExercisesToSection(sectionId, exercises);

      final sectionExercises = notifier.getExercisesForSection(sectionId);
      expect(sectionExercises, hasLength(2));
      expect(sectionExercises[0].exerciseId, 'exercise1');
      expect(sectionExercises[1].exerciseId, 'exercise2');
    });

    test('removeExerciseFromSection should remove exercise from section', () {
      final sectionId = 'section1';
      final exercises = [
        Exercise(
          id: 'exercise1',
          name: 'Test Exercise 1',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Exercise(
          id: 'exercise2',
          name: 'Test Exercise 2',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Agregar ejercicios
      notifier.addExercisesToSection(sectionId, exercises);
      expect(notifier.getExercisesForSection(sectionId), hasLength(2));

      // Obtener el ID del primer ejercicio para eliminarlo
      final firstExerciseId = notifier.getExercisesForSection(sectionId)[0].id;

      // Eliminar el primer ejercicio
      notifier.removeExerciseFromSection(sectionId, firstExerciseId);

      final remainingExercises = notifier.getExercisesForSection(sectionId);
      expect(remainingExercises, hasLength(1));
      expect(remainingExercises[0].exerciseId, 'exercise2');
    });

    test('removeExerciseFromSection should handle non-existent exercise', () {
      final sectionId = 'section1';

      // Intentar eliminar un ejercicio que no existe
      notifier.removeExerciseFromSection(sectionId, 'non-existent-id');

      // No debería haber errores y la sección debería seguir vacía
      expect(notifier.getExercisesForSection(sectionId), isEmpty);
    });

    test('removeExerciseFromSection should handle non-existent section', () {
      // Intentar eliminar de una sección que no existe
      notifier.removeExerciseFromSection('non-existent-section', 'exercise1');

      // No debería haber errores
      expect(notifier.state, isEmpty);
    });

    test('clearSection should remove all exercises from section', () {
      final sectionId = 'section1';
      final exercises = [
        Exercise(
          id: 'exercise1',
          name: 'Test Exercise 1',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Exercise(
          id: 'exercise2',
          name: 'Test Exercise 2',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Agregar ejercicios
      notifier.addExercisesToSection(sectionId, exercises);
      expect(notifier.getExercisesForSection(sectionId), hasLength(2));

      // Limpiar la sección
      notifier.clearSection(sectionId);
      expect(notifier.getExercisesForSection(sectionId), isEmpty);
    });

    test('getExercisesForSection should return empty list for non-existent section', () {
      final exercises = notifier.getExercisesForSection('non-existent-section');
      expect(exercises, isEmpty);
    });

    test('updateExerciseInSection should update exercise in section', () {
      final sectionId = 'section1';
      final exercises = [
        Exercise(
          id: 'exercise1',
          name: 'Test Exercise 1',
          description: 'Test',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Agregar ejercicio
      notifier.addExercisesToSection(sectionId, exercises);
      final originalExercise = notifier.getExercisesForSection(sectionId)[0];

      // Crear ejercicio actualizado
      final updatedExercise = originalExercise.copyWith(notes: 'Updated notes');

      // Actualizar ejercicio
      notifier.updateExerciseInSection(sectionId, originalExercise.id, updatedExercise);

      final updatedExercises = notifier.getExercisesForSection(sectionId);
      expect(updatedExercises, hasLength(1));
      expect(updatedExercises[0].notes, 'Updated notes');
    });
  });
}
