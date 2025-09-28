import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/exercise_notifier.dart';
import '../models/exercise.dart';
import '../../home/notifiers/routine_exercise_notifier.dart';

class ExerciseSelectionPage extends ConsumerStatefulWidget {
  final String? routineId;
  final String? sectionId;
  final String title;
  final String? subtitle;

  const ExerciseSelectionPage({
    super.key,
    this.routineId,
    this.sectionId,
    this.title = 'Seleccionar Ejercicios',
    this.subtitle,
  });

  @override
  ConsumerState<ExerciseSelectionPage> createState() =>
      _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends ConsumerState<ExerciseSelectionPage> {
  final Set<String> _selectedExercises = <String>{};
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Todos',
    'Pecho',
    'Espalda',
    'Piernas',
    'Hombros',
    'Brazos',
    'Core',
    'Cardio',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorScheme.surface,
        actions: [
          if (_selectedExercises.isNotEmpty)
            TextButton(
              onPressed: _addSelectedExercises,
              child: Text('Agregar (${_selectedExercises.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar ejercicios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: colorScheme.primaryContainer,
                          checkmarkColor: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Exercise List
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final exerciseAsync = ref.watch(exerciseNotifierProvider);

                return exerciseAsync.when(
                  data: (exercises) {
                    final filteredExercises = _filterExercises(exercises);

                    if (filteredExercises.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        final isSelected = _selectedExercises.contains(
                          exercise.id,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isSelected
                                      ? colorScheme.primaryContainer
                                      : colorScheme.surfaceVariant,
                              child: Icon(
                                isSelected ? Icons.check : Icons.fitness_center,
                                color:
                                    isSelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(
                              _getCategoryDisplayName(exercise.category),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    context.push('/exercise/${exercise.id}');
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isSelected
                                        ? Icons.remove_circle
                                        : Icons.add_circle,
                                    color:
                                        isSelected
                                            ? colorScheme.error
                                            : colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedExercises.remove(exercise.id);
                                      } else {
                                        _selectedExercises.add(exercise.id);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedExercises.remove(exercise.id);
                                } else {
                                  _selectedExercises.add(exercise.id);
                                }
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    var filtered = exercises;

    // Filter by category
    if (_selectedCategory != 'Todos') {
      filtered =
          filtered
              .where(
                (exercise) =>
                    _getCategoryDisplayName(exercise.category).toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();
    }

    // Filter by search text
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered =
          filtered
              .where(
                (exercise) =>
                    exercise.name.toLowerCase().contains(searchText) ||
                    exercise.description.toLowerCase().contains(searchText),
              )
              .toList();
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No se encontraron ejercicios',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar ejercicios',
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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(exerciseNotifierProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _addSelectedExercises() {
    if (_selectedExercises.isEmpty) return;

    // Get selected exercises from the exercise notifier
    final exerciseAsync = ref.read(exerciseNotifierProvider);
    exerciseAsync.whenData((exercises) {
      final selectedExercises =
          exercises
              .where((exercise) => _selectedExercises.contains(exercise.id))
              .toList();

      if (selectedExercises.isNotEmpty) {
        // Add exercises to the routine exercise notifier
        // For now, we'll add them to a default section
        final sectionId =
            widget.sectionId ?? 'main_${DateTime.now().millisecondsSinceEpoch}';
        ref
            .read(routineExerciseNotifierProvider.notifier)
            .addExercisesToSection(sectionId, selectedExercises);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedExercises.length} ejercicios agregados exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    // Navigate back
    Navigator.of(context).pop();
  }

  String _getCategoryDisplayName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Pecho';
      case ExerciseCategory.back:
        return 'Espalda';
      case ExerciseCategory.shoulders:
        return 'Hombros';
      case ExerciseCategory.arms:
        return 'Brazos';
      case ExerciseCategory.legs:
        return 'Piernas';
      case ExerciseCategory.core:
        return 'Core';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.fullBody:
        return 'Cuerpo Completo';
    }
  }
}
