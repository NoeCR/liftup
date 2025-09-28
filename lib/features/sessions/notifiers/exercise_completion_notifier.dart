import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_completion_notifier.g.dart';

@riverpod
class ExerciseCompletionNotifier extends _$ExerciseCompletionNotifier {
  @override
  Set<String> build() {
    return <String>{};
  }

  void toggleExerciseCompletion(String exerciseId) {
    final currentState = state;
    if (currentState.contains(exerciseId)) {
      state = currentState.where((id) => id != exerciseId).toSet();
    } else {
      state = {...currentState, exerciseId};
    }
  }

  bool isExerciseCompleted(String exerciseId) {
    return state.contains(exerciseId);
  }

  void clearCompletedExercises() {
    state = <String>{};
  }

  int get completedCount => state.length;
}
