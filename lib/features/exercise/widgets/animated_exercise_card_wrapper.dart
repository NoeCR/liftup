import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../notifiers/exercise_notifier.dart';
import 'animated_exercise_card.dart';

class AnimatedExerciseCardWrapper extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showFavoriteButton;

  const AnimatedExerciseCardWrapper({
    super.key,
    required this.exercise,
    this.onTap,
    this.onLongPress,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedExerciseCard(
      exercise: exercise,
      index: 0, // Index no es crítico para el wrapper
      onTap: onTap,
      onFavoriteToggle:
          showFavoriteButton
              ? () async {
                final exerciseNotifier = ref.read(exerciseNotifierProvider.notifier);
                await exerciseNotifier.toggleFavorite(exercise.id);
              }
              : null,
      onLongPress: onLongPress,
    );
  }
}
