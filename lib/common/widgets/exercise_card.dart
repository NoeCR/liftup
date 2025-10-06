import 'dart:io';
import 'package:flutter/material.dart';
import '../../features/exercise/models/exercise.dart';
import '../../features/home/models/routine.dart';
import '../themes/app_theme.dart';

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
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
                    top: Radius.circular(AppTheme.radiusL),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: colorScheme.surfaceContainerHighest,
                    child: _buildAdaptiveImage(
                      exercise?.imageUrl ?? '',
                      colorScheme,
                    ),
                  ),
                ),

                // Exercise Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise Name
                        Text(
                          exercise?.name ?? 'Ejercicio',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),

                        // Exercise Info Chips
                        Wrap(
                          spacing: AppTheme.spacingS,
                          runSpacing: AppTheme.spacingS,
                          children: [
                            _buildInfoChip(
                              context,
                              '${exercise?.defaultSets ?? 3} series',
                              Icons.repeat,
                            ),
                            _buildInfoChip(
                              context,
                              '${exercise?.defaultReps ?? 10} reps',
                              Icons.fitness_center,
                            ),
                            _buildInfoChip(
                              context,
                              '${(exercise?.defaultWeight ?? 0.0).toStringAsFixed(1)} kg',
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
                      ],
                    ),
                  ),
                ),
                if (showSetsControls) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Center(child: _buildSetsCounter(context, colorScheme)),
                  const SizedBox(height: AppTheme.spacingS),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed:
                performedSets > 0 &&
                        performedSets < (exercise?.defaultSets ?? 3)
                    ? () => onRepsChanged?.call(performedSets - 1)
                    : null,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              minimumSize: const Size(32, 32), // Better accessibility
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            '$performedSets/${exercise?.defaultSets ?? 3} series',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppTheme.spacingXS),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed:
                performedSets < (exercise?.defaultSets ?? 3)
                    ? () => onRepsChanged?.call(performedSets + 1)
                    : null,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              minimumSize: const Size(32, 32), // Better accessibility
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
      return colorScheme.primaryContainer.withValues(alpha: 0.3);
    } else if (wasPerformedThisWeek) {
      // Ejercicio realizado esta semana (fondo ámbar)
      return Colors.amber.withValues(alpha: 0.15);
    }
    // Sin estado especial
    return null;
  }
}
