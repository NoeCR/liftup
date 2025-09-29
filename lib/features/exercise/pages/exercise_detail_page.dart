import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/exercise_notifier.dart';
import '../models/exercise.dart';
import '../../../common/enums/muscle_group_enum.dart';

class ExerciseDetailPage extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailPage({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ejercicio'),
        backgroundColor: colorScheme.surface,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final exerciseAsync = ref.watch(exerciseNotifierProvider);

              return exerciseAsync.when(
                data: (exercises) {
                  final exercise = exercises.firstWhere(
                    (e) => e.id == exerciseId,
                    orElse: () => throw Exception('Ejercicio no encontrado'),
                  );

                  return PopupMenuButton<String>(
                    onSelected:
                        (value) =>
                            _handleMenuAction(value, context, ref, exercise),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final exerciseAsync = ref.watch(exerciseNotifierProvider);

          return exerciseAsync.when(
            data: (exercises) {
              final exercise = exercises.firstWhere(
                (e) => e.id == exerciseId,
                orElse: () => throw Exception('Ejercicio no encontrado'),
              );

              return _buildExerciseDetail(exercise, context);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => _buildErrorState(error.toString(), context),
          );
        },
      ),
    );
  }

  Widget _buildExerciseDetail(Exercise exercise, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Image
          _buildExerciseImage(exercise, context),

          // Exercise Info
          _buildExerciseInfo(exercise, context),

          // Muscle Groups
          _buildMuscleGroups(exercise, context),

          // Tips
          _buildTips(exercise, context),

          // Common Mistakes
          _buildCommonMistakes(exercise, context),

          // Video Section
          if (exercise.videoUrl != null) _buildVideoSection(exercise, context),
        ],
      ),
    );
  }

  Widget _buildExerciseImage(Exercise exercise, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 250,
      width: double.infinity,
      color: colorScheme.surfaceVariant,
      child:
          exercise.imageUrl.isNotEmpty
              ? Image.asset(
                exercise.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  );
                },
              )
              : Icon(
                Icons.fitness_center,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
    );
  }

  Widget _buildExerciseInfo(Exercise exercise, BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(exercise.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                _getCategoryName(exercise.category),
                Icons.category,
                context,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                _getDifficultyName(exercise.difficulty),
                Icons.trending_up,
                context,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Parámetros de entrenamiento (solo visual)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Series: 3', Icons.repeat, context),
              _buildInfoChip('Reps: 10', Icons.fitness_center, context),
              _buildInfoChip('Peso: 0.0 kg', Icons.scale, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroups(Exercise exercise, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Músculos Trabajados',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                exercise.muscleGroups.map((muscle) {
                  return Chip(
                    label: Text(muscle.displayName),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTips(Exercise exercise, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consejos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...exercise.tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: theme.textTheme.bodyMedium)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommonMistakes(Exercise exercise, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Errores Comunes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...exercise.commonMistakes.map((mistake) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(mistake, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVideoSection(Exercise exercise, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video de Demostración',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Video no disponible',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'URL: ${exercise.videoUrl}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el ejercicio',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ExerciseCategory category) {
    return category.displayName;
  }

  String _getDifficultyName(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Principiante';
      case ExerciseDifficulty.intermediate:
        return 'Intermedio';
      case ExerciseDifficulty.advanced:
        return 'Avanzado';
    }
  }

  void _handleMenuAction(
    String action,
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) {
    switch (action) {
      case 'edit':
        context.push('/exercise/edit/${exercise.id}');
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, exercise);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Ejercicio'),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${exercise.name}"? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteExercise(context, ref, exercise);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteExercise(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) async {
    try {
      await ref
          .read(exerciseNotifierProvider.notifier)
          .deleteExercise(exercise.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exercise.name} eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
