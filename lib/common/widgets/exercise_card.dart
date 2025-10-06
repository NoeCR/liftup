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
  final bool isResting;

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
    this.isResting = false,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exercise Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: _buildAdaptiveImage(exercise?.imageUrl ?? '', colorScheme),
                ),
              ),

              // Exercise Info + Controls unified
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // LEFT: Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise?.name ?? 'Ejercicio',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoChip(context, '${exercise?.defaultSets ?? 4} series', Icons.repeat),
                              const SizedBox(height: AppTheme.spacingXS),
                              _buildInfoChip(context, '${exercise?.defaultReps ?? 10} reps', Icons.fitness_center),
                              const SizedBox(height: AppTheme.spacingXS),
                              _buildInfoChip(
                                context,
                                '${(exercise?.defaultWeight ?? 0.0).toStringAsFixed(1)} kg',
                                Icons.scale,
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                              if (exercise != null)
                                _buildInfoChip(context, exercise!.category.displayName, Icons.category),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    // RIGHT: Controls (only in session), for bottom alignment match left height
                    if (showSetsControls) _buildSeriesControlColumn(context, colorScheme),
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
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: AppTheme.spacingXS),
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

  Widget _buildSeriesControlColumn(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final totalSets = exercise?.defaultSets ?? 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Text(
            '$performedSets',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: performedSets < totalSets && !isResting ? () => onRepsChanged?.call(performedSets + 1) : null,
              style: IconButton.styleFrom(
                visualDensity: VisualDensity.compact,
                fixedSize: const Size(48, 48),
                backgroundColor:
                    performedSets < totalSets && !isResting ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                foregroundColor:
                    performedSets < totalSets && !isResting ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusM)),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
        // Texto 'Series: x/y' eliminado por redundante
      ],
    );
  }

  Widget _buildAdaptiveImage(String path, ColorScheme colorScheme) {
    if (path.isEmpty) {
      return Icon(Icons.fitness_center, size: 48, color: colorScheme.onSurfaceVariant);
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 120,
        errorBuilder:
            (context, error, stackTrace) => Icon(Icons.fitness_center, size: 48, color: colorScheme.onSurfaceVariant),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 120,
        errorBuilder:
            (context, error, stackTrace) => Icon(Icons.fitness_center, size: 48, color: colorScheme.onSurfaceVariant),
      );
    }

    final String filePath = path.startsWith('file:') ? path.replaceFirst('file://', '') : path;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: 120,
      errorBuilder:
          (context, error, stackTrace) => Icon(Icons.fitness_center, size: 48, color: colorScheme.onSurfaceVariant),
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
