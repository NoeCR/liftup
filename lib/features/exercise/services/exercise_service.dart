import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exercise.dart';
import '../../../common/enums/muscle_group_enum.dart';
import '../../../core/database/database_service.dart';

part 'exercise_service.g.dart';

@riverpod
class ExerciseService extends _$ExerciseService {
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
  }

  Future<Exercise?> getExerciseById(String id) async {
    final box = _box;
    return box.get(id);
  }

  Future<List<Exercise>> getAllExercises() async {
    final box = _box;
    return box.values.cast<Exercise>().toList()
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
            (muscle) =>
                muscle.displayName.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  Future<void> deleteExercise(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<int> getExerciseCount() async {
    final box = await _box;
    return box.length;
  }

  Future<List<Exercise>> getRecentExercises({int limit = 10}) async {
    final allExercises = await getAllExercises();
    return allExercises.take(limit).toList();
  }
}
