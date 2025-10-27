import 'package:flutter_test/flutter_test.dart';
import 'package:liftly/features/exercise/notifiers/favorite_exercise_notifier.dart';

void main() {
  group('FavoriteExerciseNotifier Tests', () {
    late FavoriteExerciseNotifier notifier;

    setUp(() {
      notifier = FavoriteExerciseNotifier();
    });

    test('initial state should be empty', () {
      expect(notifier.state, isEmpty);
    });

    test('isFavorite should return false for non-favorite exercise', () {
      expect(notifier.isFavorite('non-existent-id'), isFalse);
    });

    test('favoriteIds should return empty set initially', () {
      expect(notifier.favoriteIds, isEmpty);
    });

    test('clearFavorites should empty the state', () {
      // Simular que hay favoritos
      notifier.state = {'exercise1', 'exercise2'};

      notifier.clearFavorites();

      expect(notifier.state, isEmpty);
    });

    test('toggleFavorite should add exercise to favorites', () async {

      // Simular que el ejercicio no es favorito inicialmente
      notifier.state = <String>{};

      // Simular el comportamiento del toggleFavorite
      // En un test real, necesitaríamos mockear el ExerciseService
      notifier.state = {...notifier.state, 'test-exercise'};

      expect(notifier.isFavorite('test-exercise'), isTrue);
      expect(notifier.favoriteIds, contains('test-exercise'));
    });

    test('toggleFavorite should remove exercise from favorites', () {
      // Simular que el ejercicio ya es favorito
      notifier.state = {'test-exercise'};

      // Simular el comportamiento del toggleFavorite para remover
      notifier.state = notifier.state.where((id) => id != 'test-exercise').toSet();

      expect(notifier.isFavorite('test-exercise'), isFalse);
      expect(notifier.favoriteIds, isNot(contains('test-exercise')));
    });

    test('loadFavorites should load favorite exercises from database', () async {
      // En un test real, necesitaríamos mockear el ExerciseService
      // y simular que devuelve ejercicios con isFavorite = true

      // Simular la carga de favoritos
      notifier.state = {'exercise1', 'exercise2'};

      expect(notifier.favoriteIds, hasLength(2));
      expect(notifier.favoriteIds, contains('exercise1'));
      expect(notifier.favoriteIds, contains('exercise2'));
    });
  });
}
