import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/exercise_service.dart';

part 'favorite_exercise_notifier.g.dart';

@riverpod
class FavoriteExerciseNotifier extends _$FavoriteExerciseNotifier {
  @override
  Set<String> build() {
    return <String>{};
  }

  /// Marca o desmarca un ejercicio como favorito
  Future<void> toggleFavorite(String exerciseId) async {
    try {
      // Obtener el ejercicio actual
      final exerciseService = ref.read(exerciseServiceProvider);
      final exercise = await exerciseService.getExerciseById(exerciseId);

      if (exercise == null) return;

      // Crear una copia del ejercicio con el estado de favorito invertido
      final updatedExercise = exercise.copyWith(isFavorite: !exercise.isFavorite, updatedAt: DateTime.now());

      // Guardar el ejercicio actualizado
      await exerciseService.saveExercise(updatedExercise);

      // Actualizar el estado local
      final currentFavorites = state;
      if (updatedExercise.isFavorite) {
        state = {...currentFavorites, exerciseId};
      } else {
        state = currentFavorites.where((id) => id != exerciseId).toSet();
      }
    } catch (e) {
      // En caso de error, no actualizar el estado
      print('Error al actualizar favorito: $e');
    }
  }

  /// Verifica si un ejercicio es favorito
  bool isFavorite(String exerciseId) {
    return state.contains(exerciseId);
  }

  /// Obtiene todos los IDs de ejercicios favoritos
  Set<String> get favoriteIds => state;

  /// Carga los ejercicios favoritos desde la base de datos
  Future<void> loadFavorites() async {
    try {
      final exerciseService = ref.read(exerciseServiceProvider);
      final allExercises = await exerciseService.getAllExercises();

      final favoriteIds = allExercises.where((exercise) => exercise.isFavorite).map((exercise) => exercise.id).toSet();

      state = favoriteIds;
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  /// Limpia todos los favoritos
  void clearFavorites() {
    state = <String>{};
  }
}
