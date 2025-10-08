import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exercise.dart';
import '../../../common/enums/muscle_group_enum.dart';
import '../../../core/database/database_service.dart';

part 'exercise_service.g.dart';

@riverpod
class ExerciseService extends _$ExerciseService {
  // Cache para mejorar rendimiento
  List<Exercise>? _cachedExercises;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidityDuration = Duration(seconds: 30);

  @override
  ExerciseService build() {
    return this;
  }

  Box get _box {
    return DatabaseService.getInstance().exercisesBox;
  }

  Future<void> saveExercise(Exercise exercise) async {
    final box = _box;
    await box.put(exercise.id, exercise);
    // Invalidate cache after saving
    _invalidateCache();
  }

  Future<Exercise?> getExerciseById(String id) async {
    final box = _box;
    return box.get(id);
  }

  Future<List<Exercise>> getAllExercises() async {
    final now = DateTime.now();

    // Check whether cache is valid
    if (_cachedExercises != null &&
        _lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!).compareTo(_cacheValidityDuration) <
            0) {
      return _cachedExercises!;
    }

    // Actualizar cache
    final box = _box;
    _cachedExercises =
        box.values.cast<Exercise>().toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _lastCacheUpdate = now;

    return _cachedExercises!;
  }

  Future<List<Exercise>> getExercisesByCategory(
    ExerciseCategory category,
  ) async {
    final allExercises = await getAllExercises();
    return allExercises
        .where((exercise) => exercise.category == category)
        .toList();
  }

  Future<List<Exercise>> searchExercises(String query) async {
    if (query.trim().isEmpty) return await getAllExercises();

    final allExercises = await getAllExercises();
    final lowercaseQuery = query.toLowerCase().trim();

    // Optimized search with early return
    return allExercises.where((exercise) {
      // Check name first (most common)
      if (exercise.name.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Check description
      if (exercise.description.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Check muscles worked
      for (final muscle in exercise.muscleGroups) {
        if (muscle.displayName.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Future<void> deleteExercise(String id) async {
    final box = _box;
    await box.delete(id);
    // Invalidate cache after deleting
    _invalidateCache();
  }

  Future<int> getExerciseCount() async {
    final box = _box;
    return box.length;
  }

  Future<List<Exercise>> getRecentExercises({int limit = 10}) async {
    final allExercises = await getAllExercises();
    return allExercises.take(limit).toList();
  }

  /// Invalida el cache cuando se modifican los datos
  void _invalidateCache() {
    _cachedExercises = null;
    _lastCacheUpdate = null;
  }
}
