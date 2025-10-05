import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/routine.dart';
import '../../exercise/models/exercise.dart';

part 'routine_exercise_notifier.g.dart';

@riverpod
class RoutineExerciseNotifier extends _$RoutineExerciseNotifier {
  @override
  Map<String, List<RoutineExercise>> build() {
    return <String, List<RoutineExercise>>{};
  }

  void addExercisesToSection(String sectionId, List<Exercise> exercises) {
    final currentState = state;
    final existingExercises = currentState[sectionId] ?? <RoutineExercise>[];

    final newExercises =
        exercises
            .map(
              (exercise) => RoutineExercise(
                id: '${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
                routineSectionId: sectionId,
                exerciseId: exercise.id,
                notes: '',
                order: existingExercises.length,
              ),
            )
            .toList();

    state = {
      ...currentState,
      sectionId: [...existingExercises, ...newExercises],
    };
  }

  void removeExerciseFromSection(String sectionId, String exerciseId) {
    final currentState = state;
    final exercises = currentState[sectionId] ?? <RoutineExercise>[];

    state = {...currentState, sectionId: exercises.where((exercise) => exercise.id != exerciseId).toList()};
  }

  void updateExerciseInSection(String sectionId, String exerciseId, RoutineExercise updatedExercise) {
    final currentState = state;
    final exercises = currentState[sectionId] ?? <RoutineExercise>[];

    final updatedExercises =
        exercises.map((exercise) {
          if (exercise.id == exerciseId) {
            return updatedExercise;
          }
          return exercise;
        }).toList();

    state = {...currentState, sectionId: updatedExercises};
  }

  List<RoutineExercise> getExercisesForSection(String sectionId) {
    return state[sectionId] ?? <RoutineExercise>[];
  }

  void clearSection(String sectionId) {
    final currentState = state;
    state = {...currentState, sectionId: <RoutineExercise>[]};
  }

  void clearAllSections() {
    state = <String, List<RoutineExercise>>{};
  }
}
