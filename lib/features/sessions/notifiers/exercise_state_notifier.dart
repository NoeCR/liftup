import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../home/models/routine.dart';

part 'exercise_state_notifier.g.dart';

@riverpod
class ExerciseStateNotifier extends _$ExerciseStateNotifier {
  @override
  Map<String, RoutineExercise> build() {
    return <String, RoutineExercise>{};
  }

  // Nota: Los valores de peso y repeticiones ahora se guardan en el modelo Exercise
  // Estas funciones ya no son necesarias ya que RoutineExercise no tiene estos campos
  // void updateExerciseWeight(String exerciseId, double newWeight) { ... }
  // void updateExerciseReps(String exerciseId, int newReps) { ... }

  void initializeExercise(RoutineExercise exercise) {
    final currentState = state;
    if (!currentState.containsKey(exercise.id)) {
      state = {...currentState, exercise.id: exercise};
    }
  }

  RoutineExercise? getExercise(String exerciseId) {
    return state[exerciseId];
  }

  void clearExerciseStates() {
    state = <String, RoutineExercise>{};
  }
}
