import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exercise.dart';
import '../../../core/database/database_service.dart';

part 'exercise_service.g.dart';

@riverpod
class ExerciseService extends _$ExerciseService {
  @override
  ExerciseService build() {
    return this;
  }

  Box get _box => ref.read(databaseServiceProvider.notifier).exercisesBox;

  Future<void> saveExercise(Exercise exercise) async {
    await _box.put(exercise.id, exercise);
  }

  Future<Exercise?> getExerciseById(String id) async {
    return _box.get(id);
  }

  Future<List<Exercise>> getAllExercises() async {
    return _box.values.cast<Exercise>().toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
    final allExercises = await getAllExercises();
    final lowercaseQuery = query.toLowerCase();

    return allExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lowercaseQuery) ||
          exercise.description.toLowerCase().contains(lowercaseQuery) ||
          exercise.muscleGroups.any(
            (muscle) => muscle.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  Future<void> deleteExercise(String id) async {
    await _box.delete(id);
  }

  Future<int> getExerciseCount() async {
    return _box.length;
  }

  Future<List<Exercise>> getRecentExercises({int limit = 10}) async {
    final allExercises = await getAllExercises();
    return allExercises.take(limit).toList();
  }
}
