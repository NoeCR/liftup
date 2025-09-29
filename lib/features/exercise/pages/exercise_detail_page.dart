import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/exercise_video_player.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/exercise_notifier.dart';
import '../models/exercise.dart';
import '../../../common/enums/muscle_group_enum.dart';
import '../../home/notifiers/routine_notifier.dart';

class ExerciseDetailPage extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailPage({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  final matches = exercises.where((e) => e.id == exerciseId);
                  if (matches.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final exercise = matches.first;

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
              final matches = exercises.where((e) => e.id == exerciseId);
              if (matches.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildEmptyForCreation(context),
                );
              }
              final exercise = matches.first;
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

          // Video Section / CTA añadir
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child:
                (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty)
                    ? ExerciseVideoPlayer(url: exercise.videoUrl!)
                    : _buildAddVideoCta(context, exercise),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseImage(Exercise exercise, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: colorScheme.surfaceVariant,
        child: _buildAdaptiveImage(exercise.imageUrl, colorScheme),
      ),
    );
  }

  Widget _buildAdaptiveImage(String path, ColorScheme colorScheme) {
    if (path.isEmpty) {
      return Icon(
        Icons.fitness_center,
        size: 64,
        color: colorScheme.onSurfaceVariant,
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              Icons.fitness_center,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              Icons.fitness_center,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
      );
    }

    final String filePath =
        path.startsWith('file:') ? path.replaceFirst('file://', '') : path;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Icon(
            Icons.fitness_center,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildAddVideoCta(BuildContext context, Exercise exercise) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showAddVideoSheet(context),
          icon: const Icon(Icons.video_call),
          label: const Text('Añadir video'),
        ),
      ],
    );
  }

  void _showAddVideoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Pegar URL de YouTube o .mp4'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/exercise/edit/$exerciseId');
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('Seleccionar archivo local'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/exercise/edit/$exerciseId');
                },
              ),
            ],
          ),
        );
      },
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
          // Parámetros de entrenamiento (leer desde RoutineExercise)
          Consumer(
            builder: (context, ref, _) {
              final routineAsync = ref.watch(routineNotifierProvider);
              int sets = 3;
              int reps = 10;
              double weight = 0.0;
              routineAsync.whenData((routines) {
                for (final r in routines) {
                  for (final s in r.sections) {
                    final match = s.exercises.where(
                      (re) => re.exerciseId == exercise.id,
                    );
                    if (match.isNotEmpty) {
                      final re = match.first;
                      sets = re.sets;
                      reps = re.reps;
                      weight = re.weight;
                      return; // break out once found
                    }
                  }
                }
              });

              return Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      'Series: ' + sets.toString(),
                      Icons.repeat,
                      context,
                    ),
                    _buildInfoChip(
                      'Reps: ' + reps.toString(),
                      Icons.fitness_center,
                      context,
                    ),
                    _buildInfoChip(
                      'Peso: ' + weight.toStringAsFixed(1) + ' kg',
                      Icons.scale,
                      context,
                    ),
                  ],
                ),
              );
            },
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

  Widget _buildEmptyForCreation(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Aún no hay datos para este ejercicio. Completa la información para crearlo.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.push('/exercise/create'),
          icon: const Icon(Icons.add),
          label: const Text('Crear ejercicio'),
        ),
      ],
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
