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

  const ExerciseCard({
    super.key,
    required this.routineExercise,
    this.exercise,
    this.isCompleted = false,
    this.onTap,
    this.onToggleCompleted,
    this.onWeightChanged,
    this.onRepsChanged,
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
              Padding(
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

                    // Sets and Reps
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          '${routineExercise.sets} series',
                          Icons.repeat,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          '${routineExercise.reps} reps',
                          Icons.fitness_center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Weight and Controls
                    Row(
                      children: [
                        Expanded(child: _buildWeightControl(context)),
                        const SizedBox(width: 12),
                        _buildRepsControl(context),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Complete Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onToggleCompleted,
                        icon: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                        label: Text(
                          isCompleted ? 'Completado' : 'Marcar como completado',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              isCompleted
                                  ? colorScheme.primary
                                  : colorScheme.surfaceVariant,
                          foregroundColor:
                              isCompleted
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildWeightControl(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peso (kg)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              onPressed:
                  () => onWeightChanged?.call(routineExercise.weight - 2.5),
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
              ),
            ),
            Expanded(
              child: Text(
                '${routineExercise.weight.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  () => onWeightChanged?.call(routineExercise.weight + 2.5),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepsControl(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reps',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              onPressed: () => onRepsChanged?.call(routineExercise.reps - 1),
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
              ),
            ),
            Expanded(
              child: Text(
                '${routineExercise.reps}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => onRepsChanged?.call(routineExercise.reps + 1),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
