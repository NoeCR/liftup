import 'package:flutter/material.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/home/models/routine.dart';

class ExerciseCard extends StatelessWidget {
  final RoutineExercise routineExercise;
  final Exercise? exercise;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCompleted;
  final Function(double)? onWeightChanged;
  final Function(int)? onRepsChanged;
  final int performedSets;

  const ExerciseCard({
    super.key,
    required this.routineExercise,
    this.exercise,
    this.isCompleted = false,
    this.onTap,
    this.onToggleCompleted,
    this.onWeightChanged,
    this.onRepsChanged,
    this.performedSets = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                isCompleted
                    ? colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 240, maxHeight: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: colorScheme.surfaceVariant,
                    child:
                        exercise?.imageUrl != null
                            ? Image.asset(
                              exercise!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.fitness_center,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                );
                              },
                            )
                            : Icon(
                              Icons.fitness_center,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                  ),
                ),

                // Exercise Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise Name
                        Text(
                          exercise?.name ?? 'Ejercicio',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Línea de info: series, reps, peso y categoría
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                context,
                                '${routineExercise.sets} series',
                                Icons.repeat,
                              ),
                              _buildInfoChip(
                                context,
                                '${routineExercise.reps} reps',
                                Icons.fitness_center,
                              ),
                              _buildInfoChip(
                                context,
                                '${routineExercise.weight.toStringAsFixed(1)} kg',
                                Icons.scale,
                              ),
                              if (exercise != null)
                                _buildInfoChip(
                                  context,
                                  exercise!.category.displayName,
                                  Icons.category,
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: _buildSetsCounter(context, colorScheme)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Controles eliminados de la tarjeta principal según nueva UX

  Widget _buildSetsCounter(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () => onRepsChanged?.call(performedSets - 1),
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${performedSets}/${routineExercise.sets} series',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => onRepsChanged?.call(performedSets + 1),
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
