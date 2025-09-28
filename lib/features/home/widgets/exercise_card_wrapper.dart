import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sessions/notifiers/exercise_completion_notifier.dart';
import '../../sessions/notifiers/exercise_state_notifier.dart';
import '../../../common/widgets/exercise_card.dart';
import '../models/routine.dart';
import '../../exercise/models/exercise.dart';

class ExerciseCardWrapper extends ConsumerWidget {
  final RoutineExercise routineExercise;
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseCardWrapper({
    required this.routineExercise,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize exercise state if not exists
    ref
        .read(exerciseStateNotifierProvider.notifier)
        .initializeExercise(routineExercise);

    // Get current exercise state
    final currentExercise = ref.watch(
      exerciseStateNotifierProvider.select(
        (state) => state[routineExercise.id],
      ),
    ) ?? routineExercise;

    final isCompleted = ref.watch(
      exerciseCompletionNotifierProvider.select(
        (state) => state.contains(routineExercise.id),
      ),
    );

    return ExerciseCard(
      routineExercise: currentExercise,
      exercise: exercise,
      isCompleted: isCompleted,
      onTap: onTap,
      onToggleCompleted: () {
        ref
            .read(exerciseCompletionNotifierProvider.notifier)
            .toggleExerciseCompletion(routineExercise.id);
      },
      onWeightChanged: (weight) {
        ref
            .read(exerciseStateNotifierProvider.notifier)
            .updateExerciseWeight(routineExercise.id, weight);
      },
      onRepsChanged: (reps) {
        ref
            .read(exerciseStateNotifierProvider.notifier)
            .updateExerciseReps(routineExercise.id, reps);
      },
    );
  }
}
