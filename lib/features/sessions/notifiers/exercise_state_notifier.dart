import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../home/models/routine.dart';

part 'exercise_state_notifier.g.dart';

@riverpod
class ExerciseStateNotifier extends _$ExerciseStateNotifier {
  @override
  Map<String, RoutineExercise> build() {
    return <String, RoutineExercise>{};
  }

  void updateExerciseWeight(String exerciseId, double newWeight) {
    final currentState = state;
    final exercise = currentState[exerciseId];
    if (exercise != null) {
      state = {
        ...currentState,
        exerciseId: exercise.copyWith(weight: newWeight),
      };
    }
  }

  void updateExerciseReps(String exerciseId, int newReps) {
    final currentState = state;
    final exercise = currentState[exerciseId];
    if (exercise != null) {
      state = {
        ...currentState,
        exerciseId: exercise.copyWith(reps: newReps),
      };
    }
  }

  void initializeExercise(RoutineExercise exercise) {
    final currentState = state;
    if (!currentState.containsKey(exercise.id)) {
      state = {
        ...currentState,
        exercise.id: exercise,
      };
    }
  }

  RoutineExercise? getExercise(String exerciseId) {
    return state[exerciseId];
  }

  void clearExerciseStates() {
    state = <String, RoutineExercise>{};
  }
}
