import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/models/exercise.dart';
import 'package:liftly/features/exercise/utils/exercise_sorting.dart';

void main() {
  group('Simple Exercise Sorting Tests', () {
    late List<Exercise> testExercises;

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
    });

    test('sortExercisesWithFavoritesFirst should put favorites first', () {
      final sorted = sortExercisesWithFavoritesFirst(testExercises);

      // Los favoritos deben estar primero
      expect(sorted[0].isFavorite, isTrue);
      expect(sorted[1].isFavorite, isTrue);
      expect(sorted[2].isFavorite, isFalse);
      expect(sorted[3].isFavorite, isFalse);

      // Verificar que los favoritos son 'Press de Banca' y 'Flexiones'
      expect(sorted[0].name, anyOf(['Press de Banca', 'Flexiones']));
      expect(sorted[1].name, anyOf(['Press de Banca', 'Flexiones']));
    });

    test('sortExercisesWithFavoritesFirstByName should sort favorites first, then by name', () {
      final sorted = sortExercisesWithFavoritesFirstByName(testExercises);

      // Los favoritos deben estar primero
      expect(sorted[0].isFavorite, isTrue);
      expect(sorted[1].isFavorite, isTrue);
      expect(sorted[2].isFavorite, isFalse);
      expect(sorted[3].isFavorite, isFalse);

      // Dentro de los favoritos, deben estar ordenados por nombre
      expect(sorted[0].name, 'Flexiones'); // F viene antes que P
      expect(sorted[1].name, 'Press de Banca');

      // Dentro de los no favoritos, deben estar ordenados por nombre
      expect(sorted[2].name, 'Dominadas'); // D viene antes que S
      expect(sorted[3].name, 'Sentadillas');
    });

    test('sortExercisesWithFavoritesFirstByCategory should sort favorites first, then by category', () {
      final sorted = sortExercisesWithFavoritesFirstByCategory(testExercises);

      // Los favoritos deben estar primero
      expect(sorted[0].isFavorite, isTrue);
      expect(sorted[1].isFavorite, isTrue);
      expect(sorted[2].isFavorite, isFalse);
      expect(sorted[3].isFavorite, isFalse);

      // Dentro de los favoritos, deben estar ordenados por categoría
      expect(sorted[0].category, ExerciseCategory.chest);
      expect(sorted[1].category, ExerciseCategory.chest);

      // Dentro de los no favoritos, deben estar ordenados por categoría
      expect(sorted[2].category, ExerciseCategory.back); // back viene antes que quadriceps
      expect(sorted[3].category, ExerciseCategory.quadriceps);
    });

    test('should handle empty list', () {
      final sorted = sortExercisesWithFavoritesFirst([]);
      expect(sorted, isEmpty);
    });

    test('should handle list with only favorites', () {
      final onlyFavorites = testExercises.where((e) => e.isFavorite).toList();
      final sorted = sortExercisesWithFavoritesFirst(onlyFavorites);

      expect(sorted.length, 2);
      expect(sorted.every((e) => e.isFavorite), isTrue);
    });

    test('should handle list with no favorites', () {
      final noFavorites = testExercises.where((e) => !e.isFavorite).toList();
      final sorted = sortExercisesWithFavoritesFirst(noFavorites);

      expect(sorted.length, 2);
      expect(sorted.every((e) => !e.isFavorite), isTrue);
    });

    test('should maintain order within favorites and non-favorites', () {
      // Crear ejercicios con diferentes fechas de actualización
      final exercisesWithDates = [
        testExercises[0].copyWith(updatedAt: DateTime.now().subtract(const Duration(days: 3))),
        testExercises[1].copyWith(updatedAt: DateTime.now().subtract(const Duration(days: 1))),
        testExercises[2].copyWith(updatedAt: DateTime.now().subtract(const Duration(days: 2))),
        testExercises[3].copyWith(updatedAt: DateTime.now()),
      ];

      final sorted = sortExercisesWithFavoritesFirst(exercisesWithDates);

      // Verificar que los favoritos están primero
      expect(sorted[0].isFavorite, isTrue);
      expect(sorted[1].isFavorite, isTrue);
      expect(sorted[2].isFavorite, isFalse);
      expect(sorted[3].isFavorite, isFalse);

      // Verificar que dentro de cada grupo, están ordenados por fecha de actualización
      // (más recientes primero)
      expect(sorted[0].name, 'Flexiones'); // Más reciente
      expect(sorted[1].name, 'Press de Banca'); // Menos reciente
    });

    test('should handle mixed favorite and non-favorite exercises correctly', () {
      // Crear una lista mixta de ejercicios
      final mixedExercises = [
        testExercises[0], // No favorito
        testExercises[1], // Favorito
        testExercises[2], // No favorito
        testExercises[3], // Favorito
      ];

      final sorted = sortExercisesWithFavoritesFirst(mixedExercises);

      // Verificar orden correcto
      expect(sorted[0].isFavorite, isTrue);
      expect(sorted[1].isFavorite, isTrue);
      expect(sorted[2].isFavorite, isFalse);
      expect(sorted[3].isFavorite, isFalse);
    });
  });
}
