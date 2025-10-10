import '../../exercise/models/exercise.dart';
import '../../home/models/routine.dart';

/// Enum for different exercise sorting types
enum ExerciseSortType { name, lastPerformed, category }

/// Helper class for exercise search operations in UI
class ExerciseSearchHelper {
  /// Creates a map of exercise ID to Exercise for efficient lookups
  static Map<String, Exercise> createExerciseMap(List<Exercise> exercises) {
    final Map<String, Exercise> exerciseMap = {};
    for (final exercise in exercises) {
      exerciseMap[exercise.id] = exercise;
    }
    return exerciseMap;
  }

  /// Creates a map of routine ID to Routine for efficient lookups
  static Map<String, Routine> createRoutineMap(List<Routine> routines) {
    final Map<String, Routine> routineMap = {};
    for (final routine in routines) {
      routineMap[routine.id] = routine;
    }
    return routineMap;
  }

  /// Gets an exercise by ID with fallback
  static Exercise? getExerciseById(String exerciseId, Map<String, Exercise> exerciseMap) {
    return exerciseMap[exerciseId];
  }

  /// Gets an exercise by ID with fallback to default exercise
  static Exercise getExerciseByIdWithFallback(
    String exerciseId,
    Map<String, Exercise> exerciseMap, {
    String? defaultName,
  }) {
    final exercise = exerciseMap[exerciseId];
    if (exercise != null) return exercise;

    // Return default exercise if not found
    return Exercise(
      id: '',
      name: defaultName ?? 'Ejercicio',
      description: '',
      imageUrl: '',
      muscleGroups: const [],
      tips: const [],
      commonMistakes: const [],
      category: ExerciseCategory.fullBody,
      difficulty: ExerciseDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Gets a routine by ID with fallback
  static Routine? getRoutineById(String routineId, Map<String, Routine> routineMap) {
    return routineMap[routineId];
  }

  /// Sorts exercises by name for consistent display order
  static List<Exercise> sortExercisesByName(List<Exercise> exercises) {
    final sortedExercises = [...exercises];
    sortedExercises.sort((a, b) => a.name.compareTo(b.name));
    return sortedExercises;
  }

  /// Sorts routines by name for consistent display order
  static List<Routine> sortRoutinesByName(List<Routine> routines) {
    final sortedRoutines = [...routines];
    sortedRoutines.sort((a, b) => a.name.compareTo(b.name));
    return sortedRoutines;
  }

  /// Groups exercises by category
  static Map<ExerciseCategory, List<Exercise>> groupExercisesByCategory(List<Exercise> exercises) {
    final Map<ExerciseCategory, List<Exercise>> grouped = {};
    for (final exercise in exercises) {
      grouped.putIfAbsent(exercise.category, () => []).add(exercise);
    }
    return grouped;
  }

  /// Searches exercises by name (case-insensitive)
  static List<Exercise> searchExercisesByName(List<Exercise> exercises, String query) {
    if (query.isEmpty) return exercises;

    final lowercaseQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Searches exercises by muscle group
  static List<Exercise> searchExercisesByMuscleGroup(List<Exercise> exercises, String muscleGroup) {
    if (muscleGroup.isEmpty) return exercises;

    final lowercaseMuscleGroup = muscleGroup.toLowerCase();
    return exercises.where((exercise) {
      return exercise.muscleGroups.any((mg) => mg.name.toLowerCase().contains(lowercaseMuscleGroup));
    }).toList();
  }

  /// Creates a sorted list of routine exercises with their corresponding Exercise objects
  static List<({RoutineExercise routineExercise, Exercise exercise})> createSortedExerciseList(
    List<RoutineExercise> routineExercises,
    List<Exercise> exercises, {
    String? defaultName,
    ExerciseSortType sortType = ExerciseSortType.name,
  }) {
    final exerciseMap = createExerciseMap(exercises);

    final List<({RoutineExercise routineExercise, Exercise exercise})> exerciseList = [];

    for (final routineExercise in routineExercises) {
      final exercise = getExerciseByIdWithFallback(
        routineExercise.exerciseId,
        exerciseMap,
        defaultName: defaultName ?? 'Ejercicio',
      );
      exerciseList.add((routineExercise: routineExercise, exercise: exercise));
    }

    // Sort based on specified type
    switch (sortType) {
      case ExerciseSortType.name:
        exerciseList.sort((a, b) => a.exercise.name.compareTo(b.exercise.name));
        break;
      case ExerciseSortType.lastPerformed:
        exerciseList.sort((a, b) {
          final aDate = a.exercise.lastPerformedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.exercise.lastPerformedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate); // older first
        });
        break;
      case ExerciseSortType.category:
        exerciseList.sort((a, b) => a.exercise.category.name.compareTo(b.exercise.category.name));
        break;
    }

    return exerciseList;
  }
}
