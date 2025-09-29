import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sessions/notifiers/exercise_completion_notifier.dart';
import '../../sessions/notifiers/exercise_state_notifier.dart';
import '../../sessions/notifiers/performed_sets_notifier.dart';
import '../../../common/widgets/exercise_card.dart';
import '../models/routine.dart';
import '../../exercise/models/exercise.dart';

class ExerciseCardWrapper extends ConsumerStatefulWidget {
  final RoutineExercise routineExercise;
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseCardWrapper({
    required this.routineExercise,
    required this.exercise,
    required this.onTap,
    super.key,
  });

  @override
  ConsumerState<ExerciseCardWrapper> createState() =>
      _ExerciseCardWrapperState();
}

class _ExerciseCardWrapperState extends ConsumerState<ExerciseCardWrapper> {
  @override
  void initState() {
    super.initState();
    // Defer provider modification until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(exerciseStateNotifierProvider.notifier)
          .initializeExercise(widget.routineExercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current exercise state
    final currentExercise =
        ref.watch(
          exerciseStateNotifierProvider.select(
            (state) => state[widget.routineExercise.id],
          ),
        ) ??
        widget.routineExercise;

    final isCompleted = ref.watch(
      exerciseCompletionNotifierProvider.select(
        (state) => state.contains(widget.routineExercise.id),
      ),
    );

    // progreso de series realizadas
    // read current performed sets if needed for future display/logic
    // final performedSets = ref.watch(performedSetsNotifierProvider)[widget.routineExercise.id] ?? 0;

    return ExerciseCard(
      routineExercise: currentExercise,
      exercise: widget.exercise,
      isCompleted: isCompleted,
      performedSets:
          ref.watch(performedSetsNotifierProvider)[widget.routineExercise.id] ??
          0,
      onTap: widget.onTap,
      onToggleCompleted: null,
      onWeightChanged: null,
      onRepsChanged: (newValue) {
        // Usamos este callback como contador de series realizadas (independiente de reps configuradas)
        final totalSets = currentExercise.sets;
        final int clamped = newValue.clamp(0, totalSets).toInt();
        ref
            .read(performedSetsNotifierProvider.notifier)
            .setCount(widget.routineExercise.id, clamped);

        final nowCompleted = clamped >= totalSets;
        final completion = ref.read(
          exerciseCompletionNotifierProvider.notifier,
        );
        final already = ref
            .read(exerciseCompletionNotifierProvider)
            .contains(widget.routineExercise.id);
        if (nowCompleted && !already) {
          completion.toggleExerciseCompletion(widget.routineExercise.id);
        } else if (!nowCompleted && already) {
          completion.toggleExerciseCompletion(widget.routineExercise.id);
        }
      },
    );
  }
}
