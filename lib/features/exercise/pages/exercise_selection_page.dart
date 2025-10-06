import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/exercise_notifier.dart';
import '../models/exercise.dart';
import '../../home/notifiers/routine_exercise_notifier.dart';
import '../../home/notifiers/routine_notifier.dart';
import '../../home/models/routine.dart';

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
  ConsumerState<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends ConsumerState<ExerciseSelectionPage> {
  final Set<String> _selectedExercises = <String>{};
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  // Default values for new routine assignments
  int _defaultSets = 3;
  int _defaultReps = 10;
  double _defaultWeight = 0.0;
  int _defaultRestSeconds = 60;

  final List<String> _categories = ['Todos', ...ExerciseCategory.values.map((category) => category.displayName)];

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
              child: Text(context.tr('exercises.addCount', namedArgs: {'count': _selectedExercises.length.toString()})),
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
                    hintText: context.tr('exercises.searchExercises'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      itemCount: filteredExercises.length + 1,
                      itemBuilder: (context, index) {
                        // First item: create a new exercise
                        if (index == 0) {
                          return _buildCreateExerciseItem(context, colorScheme);
                        }

                        final exercise = filteredExercises[index - 1];
                        final isSelected = _selectedExercises.contains(exercise.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
                              child: Icon(
                                isSelected ? Icons.check : Icons.fitness_center,
                                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(exercise.name),
                            subtitle: Text(
                              exercise.category.displayName,
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
                                    isSelected ? Icons.remove_circle : Icons.add_circle,
                                    color: isSelected ? colorScheme.error : colorScheme.primary,
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
                  loading: () => const Center(child: CircularProgressIndicator()),
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
              .where((exercise) => exercise.category.displayName.toLowerCase() == _selectedCategory.toLowerCase())
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

    final bool isSearching = _searchController.text.isNotEmpty;
    final bool isFiltering = _selectedCategory != 'Todos';

    String title;
    String subtitle;
    IconData icon;

    if (isSearching) {
      title = context.tr('exercises.noExercisesFound');
      subtitle = context.tr('exercises.tryOtherSearchTerms');
      icon = Icons.search_off;
    } else if (isFiltering) {
      title = context.tr('exercises.noExercisesInCategory');
      subtitle = context.tr('exercises.noExercisesForCategory', namedArgs: {'category': _selectedCategory});
      icon = Icons.category_outlined;
    } else {
      title = context.tr('exercises.noExercisesYet');
      subtitle = context.tr('exercises.startAddingFirstExercise');
      icon = Icons.fitness_center_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Action: create new exercise
            FilledButton.icon(
              onPressed: () {
                final queryParams = <String, String>{};
                if (widget.routineId != null) {
                  queryParams['routineId'] = widget.routineId!;
                }
                if (widget.sectionId != null) {
                  queryParams['sectionId'] = widget.sectionId!;
                }
                queryParams['returnTo'] = 'selection';

                final uri = Uri(path: '/exercise/create', queryParameters: queryParams);
                context.push(uri.toString());
              },
              icon: const Icon(Icons.add),
              label: Text(context.tr('exercises.addExercise')),
            ),
            const SizedBox(height: 12),
            // Secondary actions depending on context
            if (isSearching)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
                label: Text(context.tr('exercises.clearSearch')),
              ),
            if (isFiltering)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'Todos';
                  });
                },
                child: Text(context.tr('exercises.viewAllExercises')),
              ),
          ],
        ),
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
          Text('Error al cargar ejercicios', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.invalidate(exerciseNotifierProvider);
            },
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('common.retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateExerciseItem(BuildContext context, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(context.tr('exercises.createNewExercise')),
        subtitle: Text(context.tr('exercises.addExerciseAndReturn')),
        // sin icono para mantenerlo limpio
        trailing: null,
        onTap: () {
          final queryParams = <String, String>{};
          if (widget.routineId != null) {
            queryParams['routineId'] = widget.routineId!;
          }
          if (widget.sectionId != null) {
            queryParams['sectionId'] = widget.sectionId!;
          }
          queryParams['returnTo'] = 'selection';

          final uri = Uri(path: '/exercise/create', queryParameters: queryParams);
          context.push(uri.toString());
        },
      ),
    );
  }

  void _addSelectedExercises() {
    if (_selectedExercises.isEmpty) return;
    _confirmDefaultsAndAdd();
  }

  Future<void> _confirmDefaultsAndAdd() async {
    // Prefill with previously used values when a single exercise is selected
    if (_selectedExercises.length == 1) {
      final exerciseId = _selectedExercises.first;
      final params = _findLastUsedParamsForExercise(exerciseId);
      if (params != null) {
        _defaultSets = params['sets'] as int;
        _defaultReps = params['reps'] as int;
        _defaultWeight = params['weight'] as double;
        _defaultRestSeconds = params['rest'] as int;
      }
    }

    final setsController = TextEditingController(text: _defaultSets.toString());
    final repsController = TextEditingController(text: _defaultReps.toString());
    final weightController = TextEditingController(text: _defaultWeight.toStringAsFixed(1));
    final restController = TextEditingController(text: _defaultRestSeconds.toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('exercises.configureSetsRepsWeight')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('exercises.sets'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('exercises.reps'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: context.tr('exercises.weight'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: restController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr('exercises.restSeconds'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.tr('common.cancel'))),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.tr('common.confirm'))),
          ],
        );
      },
    );

    if (!context.mounted) return;
    if (confirmed != true) return;

    final parsedSets = int.tryParse(setsController.text.trim()) ?? _defaultSets;
    final parsedReps = int.tryParse(repsController.text.trim()) ?? _defaultReps;
    final parsedWeight = double.tryParse(weightController.text.trim()) ?? _defaultWeight;
    final parsedRest = int.tryParse(restController.text.trim()) ?? _defaultRestSeconds;

    _defaultSets = parsedSets;
    _defaultReps = parsedReps;
    _defaultWeight = parsedWeight;
    _defaultRestSeconds = parsedRest;

    // Get selected exercises from the exercise notifier
    final exerciseAsync = ref.read(exerciseNotifierProvider);
    final exercises = exerciseAsync.valueOrNull;

    if (exercises != null) {
      final selectedExercises = exercises.where((exercise) => _selectedExercises.contains(exercise.id)).toList();

      if (selectedExercises.isNotEmpty) {
        // Add exercises to the routine exercise notifier
        final sectionId = widget.sectionId ?? 'main_${DateTime.now().millisecondsSinceEpoch}';
        ref.read(routineExerciseNotifierProvider.notifier).addExercisesToSection(sectionId, selectedExercises);

        // If we have a routineId, we should also update the routine in the database
        if (widget.routineId != null) {
          _updateRoutineWithExercises(
            widget.routineId!,
            sectionId,
            selectedExercises,
            sets: parsedSets,
            reps: parsedReps,
            weight: parsedWeight,
            restTime: parsedRest,
          );
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedExercises.length} ejercicios agregados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    // Safe navigation: pop if possible, otherwise go to Home
    if (!mounted) return;
    if (Navigator.canPop(context)) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _updateRoutineWithExercises(
    String routineId,
    String sectionId,
    List<Exercise> exercises, {
    required int sets,
    required int reps,
    required double weight,
    required int restTime,
  }) async {
    // Primero, actualizar los valores por defecto en cada ejercicio
    for (final exercise in exercises) {
      final updatedExercise = exercise.copyWith(
        defaultSets: sets,
        defaultReps: reps,
        defaultWeight: weight,
        restTimeSeconds: restTime,
      );

      // Guardar el ejercicio actualizado
      await ref.read(exerciseNotifierProvider.notifier).updateExercise(updatedExercise);
    }

    // Get current routine
    final routineAsync = ref.read(routineNotifierProvider);
    routineAsync.whenData((routines) {
      final routine = routines.firstWhere((r) => r.id == routineId, orElse: () => throw Exception('Routine not found'));

      // Create RoutineExercise objects (weight/sets/reps now stored in Exercise)
      final routineExercises =
          exercises
              .map(
                (exercise) => RoutineExercise(
                  id: '${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
                  routineSectionId: sectionId,
                  exerciseId: exercise.id,
                  notes: '',
                  order: 0,
                ),
              )
              .toList();

      // Update the routine with new exercises
      final updatedSections =
          routine.sections.map((section) {
            if (section.id == sectionId) {
              return section.copyWith(exercises: [...section.exercises, ...routineExercises]);
            }
            return section;
          }).toList();

      final updatedRoutine = routine.copyWith(sections: updatedSections, updatedAt: DateTime.now());

      // Save the updated routine
      ref.read(routineNotifierProvider.notifier).updateRoutine(updatedRoutine);
    });
  }

  /// Looks up last used parameters for an exercise from the Exercise model
  Map<String, Object>? _findLastUsedParamsForExercise(String exerciseId) {
    final exercises = ref.read(exerciseNotifierProvider).valueOrNull;
    if (exercises == null) return null;

    final exercise = exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Exercise not found'),
    );

    return <String, Object>{
      'sets': exercise.defaultSets ?? 3,
      'reps': exercise.defaultReps ?? 10,
      'weight': exercise.defaultWeight ?? 0.0,
      'rest': exercise.restTimeSeconds ?? _defaultRestSeconds,
    };
  }
}
