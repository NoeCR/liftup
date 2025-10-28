import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/models/routine.dart';
import '../../home/widgets/exercise_card_wrapper.dart';
import '../models/exercise.dart';
import '../notifiers/exercise_notifier.dart';

class FavoriteExerciseWrapper extends ConsumerWidget {
  final RoutineExercise routineExercise;
  final Exercise exercise;
  final VoidCallback onTap;
  final bool showSetsControls;
  final String? routineId;

  const FavoriteExerciseWrapper({
    super.key,
    required this.routineExercise,
    required this.exercise,
    required this.onTap,
    this.showSetsControls = false,
    this.routineId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExerciseCardWrapper(
      routineExercise: routineExercise,
      exercise: exercise,
      onTap: onTap,
      showSetsControls: showSetsControls,
      routineId: routineId,
      // Añadir callback para el botón de favorito
      onFavoriteToggle: () async {
        try {
          final exerciseNotifier = ref.read(exerciseNotifierProvider.notifier);
          await exerciseNotifier.toggleFavorite(exercise.id);

          // Feedback háptico
          HapticFeedback.lightImpact();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al actualizar favorito: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
    );
  }
}
