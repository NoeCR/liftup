import 'dart:io';
import 'package:flutter/material.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/home/models/routine.dart';

class ExerciseCard extends StatelessWidget {
  final RoutineExercise routineExercise;
  final Exercise? exercise;
  final bool isCompleted;
  final bool wasPerformedThisWeek;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleCompleted;
  final Function(double)? onWeightChanged;
  final Function(int)? onRepsChanged;
  final int performedSets;
  final bool showSetsControls;

  const ExerciseCard({
    super.key,
    required this.routineExercise,
    this.exercise,
    this.isCompleted = false,
    this.wasPerformedThisWeek = false,
    this.onTap,
    this.onLongPress,
    this.onToggleCompleted,
    this.onWeightChanged,
    this.onRepsChanged,
    this.performedSets = 0,
    this.showSetsControls = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _getCardBackgroundColor(colorScheme),
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
                    child: _buildAdaptiveImage(
                      exercise?.imageUrl ?? '',
                      colorScheme,
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
                if (showSetsControls) ...[
                  const SizedBox(height: 8),
                  Center(child: _buildSetsCounter(context, colorScheme)),
                  const SizedBox(height: 8),
                ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: performedSets > 0 ? () => onRepsChanged?.call(performedSets - 1) : null,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
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
            icon: const Icon(Icons.add, size: 16),
            onPressed: performedSets < routineExercise.sets ? () => onRepsChanged?.call(performedSets + 1) : null,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveImage(String path, ColorScheme colorScheme) {
    if (path.isEmpty) {
      return Icon(
        Icons.fitness_center,
        size: 48,
        color: colorScheme.onSurfaceVariant,
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 120,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              Icons.fitness_center,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 120,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              Icons.fitness_center,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
      );
    }

    final String filePath =
        path.startsWith('file:') ? path.replaceFirst('file://', '') : path;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: 120,
      errorBuilder:
          (context, error, stackTrace) => Icon(
            Icons.fitness_center,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }

  /// Determina el color de fondo de la tarjeta basado en el estado del ejercicio
  Color? _getCardBackgroundColor(ColorScheme colorScheme) {
    if (isCompleted) {
      // Ejercicio completado en la sesión actual
      return colorScheme.primaryContainer.withOpacity(0.3);
    } else if (wasPerformedThisWeek) {
      // Ejercicio realizado esta semana (fondo ámbar)
      return Colors.amber.withOpacity(0.15);
    }
    // Sin estado especial
    return null;
  }
}
