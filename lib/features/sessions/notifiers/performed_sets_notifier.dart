import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerformedSetsNotifier extends StateNotifier<Map<String, int>> {
  PerformedSetsNotifier() : super(<String, int>{});

  int getCount(String routineExerciseId) => state[routineExerciseId] ?? 0;

  void setCount(String routineExerciseId, int count) {
    state = {...state, routineExerciseId: count};
  }

  void increment(String routineExerciseId, int maxSets) {
    final current = getCount(routineExerciseId);
    if (current < maxSets) setCount(routineExerciseId, current + 1);
  }

  void decrement(String routineExerciseId, int maxSets) {
    final current = getCount(routineExerciseId);
    if (current > 0) setCount(routineExerciseId, current - 1);
  }

  void clearAll() {
    state = <String, int>{};
  }
}

final performedSetsNotifierProvider = StateNotifierProvider<PerformedSetsNotifier, Map<String, int>>(
  (ref) => PerformedSetsNotifier(),
);
