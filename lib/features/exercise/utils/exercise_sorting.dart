import '../models/exercise.dart';

/// Ordena una lista de ejercicios poniendo los favoritos primero
List<Exercise> sortExercisesWithFavoritesFirst(List<Exercise> exercises) {
  final sortedExercises = List<Exercise>.from(exercises);

  // Ordenar: favoritos primero, luego por fecha de actualización (más recientes primero)
  sortedExercises.sort((a, b) {
    // Si uno es favorito y el otro no, el favorito va primero
    if (a.isFavoriteValue && !b.isFavoriteValue) return -1;
    if (!a.isFavoriteValue && b.isFavoriteValue) return 1;

    // Si ambos son favoritos o ninguno es favorito, ordenar por fecha de actualización
    return b.updatedAt.compareTo(a.updatedAt);
  });

  return sortedExercises;
}

/// Ordena una lista de ejercicios con favoritos primero y luego por nombre
List<Exercise> sortExercisesWithFavoritesFirstByName(List<Exercise> exercises) {
  final sortedExercises = List<Exercise>.from(exercises);

  // Ordenar: favoritos primero, luego por nombre alfabéticamente
  sortedExercises.sort((a, b) {
    // Si uno es favorito y el otro no, el favorito va primero
    if (a.isFavoriteValue && !b.isFavoriteValue) return -1;
    if (!a.isFavoriteValue && b.isFavoriteValue) return 1;

    // Si ambos son favoritos o ninguno es favorito, ordenar por nombre
    return a.name.compareTo(b.name);
  });

  return sortedExercises;
}

/// Ordena una lista de ejercicios con favoritos primero y luego por categoría
List<Exercise> sortExercisesWithFavoritesFirstByCategory(List<Exercise> exercises) {
  final sortedExercises = List<Exercise>.from(exercises);

  // Ordenar: favoritos primero, luego por categoría
  sortedExercises.sort((a, b) {
    // Si uno es favorito y el otro no, el favorito va primero
    if (a.isFavoriteValue && !b.isFavoriteValue) return -1;
    if (!a.isFavoriteValue && b.isFavoriteValue) return 1;

    // Si ambos son favoritos o ninguno es favorito, ordenar por categoría
    return a.category.name.compareTo(b.category.name);
  });

  return sortedExercises;
}
