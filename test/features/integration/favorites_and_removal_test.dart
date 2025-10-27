import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/exercise/utils/exercise_sorting.dart';
import 'package:liftly/features/home/notifiers/routine_exercise_notifier.dart';

void main() {
  group('Favorites and Removal Integration Tests', () {
    late List<Exercise> testExercises;
    late RoutineExerciseNotifier routineExerciseNotifier;

    setUp(() {
      testExercises = [
        Exercise(
          id: '1',
          name: 'Sentadillas',
          description: 'Ejercicio básico',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.quadriceps,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          isFavorite: false,
        ),
        Exercise(
          id: '2',
          name: 'Press de Banca',
          description: 'Ejercicio de pecho',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.intermediate,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          isFavorite: true,
        ),
        Exercise(
          id: '3',
          name: 'Dominadas',
          description: 'Ejercicio de espalda',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.back,
          difficulty: ExerciseDifficulty.advanced,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          isFavorite: false,
        ),
        Exercise(
          id: '4',
          name: 'Flexiones',
          description: 'Ejercicio de pecho',
          imageUrl: '',
          muscleGroups: [],
          tips: [],
          commonMistakes: [],
          category: ExerciseCategory.chest,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFavorite: true,
        ),
      ];

      routineExerciseNotifier = RoutineExerciseNotifier();
    });

    test('should maintain favorites first ordering after adding exercises to routine', () {
      // Agregar ejercicios a una sección de rutina
      final sectionId = 'chest-section';
      routineExerciseNotifier.addExercisesToSection(sectionId, testExercises);

      // Obtener los ejercicios de la sección
      final sectionExercises = routineExerciseNotifier.getExercisesForSection(sectionId);

      // Convertir a objetos Exercise para el ordenamiento
      final exercises = sectionExercises.map((re) => testExercises.firstWhere((e) => e.id == re.exerciseId)).toList();

      // Aplicar ordenamiento con favoritos primero
      final sortedExercises = sortExercisesWithFavoritesFirst(exercises);

      // Verificar que los favoritos están primero
      expect(sortedExercises[0].isFavorite, isTrue);
      expect(sortedExercises[1].isFavorite, isTrue);
      expect(sortedExercises[2].isFavorite, isFalse);
      expect(sortedExercises[3].isFavorite, isFalse);

      // Verificar que los favoritos son 'Press de Banca' y 'Flexiones'
      final favoriteNames = sortedExercises.where((e) => e.isFavorite).map((e) => e.name).toList();
      expect(favoriteNames, contains('Press de Banca'));
      expect(favoriteNames, contains('Flexiones'));
    });

    test('should maintain favorites first ordering after removing exercises from routine', () {
      // Agregar ejercicios a una sección de rutina
      final sectionId = 'chest-section';
      routineExerciseNotifier.addExercisesToSection(sectionId, testExercises);

      // Obtener el ID del primer ejercicio (no favorito)
      final sectionExercises = routineExerciseNotifier.getExercisesForSection(sectionId);
      final firstExerciseId = sectionExercises.first.id;

      // Eliminar el primer ejercicio
      routineExerciseNotifier.removeExerciseFromSection(sectionId, firstExerciseId);

      // Obtener los ejercicios restantes
      final remainingExercises = routineExerciseNotifier.getExercisesForSection(sectionId);
      final exercises = remainingExercises.map((re) => testExercises.firstWhere((e) => e.id == re.exerciseId)).toList();

      // Aplicar ordenamiento con favoritos primero
      final sortedExercises = sortExercisesWithFavoritesFirst(exercises);

      // Verificar que los favoritos siguen estando primero
      expect(sortedExercises[0].isFavorite, isTrue);
      expect(sortedExercises[1].isFavorite, isTrue);
      expect(sortedExercises[2].isFavorite, isFalse);
    });

    test('should handle mixed favorite and non-favorite exercises correctly', () {
      // Crear una lista mixta de ejercicios
      final mixedExercises = [
        testExercises[0], // No favorito
        testExercises[1], // Favorito
        testExercises[2], // No favorito
        testExercises[3], // Favorito
      ];

      // Agregar a una sección
      final sectionId = 'mixed-section';
      routineExerciseNotifier.addExercisesToSection(sectionId, mixedExercises);

      // Obtener y ordenar
      final sectionExercises = routineExerciseNotifier.getExercisesForSection(sectionId);
      final exercises = sectionExercises.map((re) => testExercises.firstWhere((e) => e.id == re.exerciseId)).toList();
      final sortedExercises = sortExercisesWithFavoritesFirst(exercises);

      // Verificar orden correcto
      expect(sortedExercises[0].isFavorite, isTrue);
      expect(sortedExercises[1].isFavorite, isTrue);
      expect(sortedExercises[2].isFavorite, isFalse);
      expect(sortedExercises[3].isFavorite, isFalse);
    });

    test('should handle empty section correctly', () {
      final sectionId = 'empty-section';

      // Verificar que la sección está vacía
      expect(routineExerciseNotifier.getExercisesForSection(sectionId), isEmpty);

      // Intentar eliminar de una sección vacía no debería causar errores
      routineExerciseNotifier.removeExerciseFromSection(sectionId, 'non-existent-id');
      expect(routineExerciseNotifier.getExercisesForSection(sectionId), isEmpty);
    });

    test('should maintain exercise order within favorites and non-favorites', () {
      // Crear ejercicios con diferentes fechas de actualización
      final exercisesWithDates = [
        testExercises[0].copyWith(updatedAt: DateTime.now().subtract(const Duration(days: 3))),
        testExercises[1].copyWith(updatedAt: DateTime.now().subtract(const Duration(days: 1))),
        testExercises[2].copyWith(updatedAt: DateTime.now().subtract(const Duration(days: 2))),
        testExercises[3].copyWith(updatedAt: DateTime.now()),
      ];

      // Agregar a una sección
      final sectionId = 'date-test-section';
      routineExerciseNotifier.addExercisesToSection(sectionId, exercisesWithDates);

      // Obtener y ordenar
      final sectionExercises = routineExerciseNotifier.getExercisesForSection(sectionId);
      final exercises =
          sectionExercises.map((re) => exercisesWithDates.firstWhere((e) => e.id == re.exerciseId)).toList();
      final sortedExercises = sortExercisesWithFavoritesFirst(exercises);

      // Verificar que los favoritos están primero
      expect(sortedExercises[0].isFavorite, isTrue);
      expect(sortedExercises[1].isFavorite, isTrue);
      expect(sortedExercises[2].isFavorite, isFalse);
      expect(sortedExercises[3].isFavorite, isFalse);

      // Verificar que dentro de cada grupo, están ordenados por fecha de actualización
      // (más recientes primero)
      expect(sortedExercises[0].name, 'Flexiones'); // Más reciente
      expect(sortedExercises[1].name, 'Press de Banca'); // Menos reciente
    });

    test('should handle section clearing correctly', () {
      final sectionId = 'clear-test-section';

      // Agregar ejercicios
      routineExerciseNotifier.addExercisesToSection(sectionId, testExercises);
      expect(routineExerciseNotifier.getExercisesForSection(sectionId), hasLength(4));

      // Limpiar la sección
      routineExerciseNotifier.clearSection(sectionId);
      expect(routineExerciseNotifier.getExercisesForSection(sectionId), isEmpty);
    });
  });
}
