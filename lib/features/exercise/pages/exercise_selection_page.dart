import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  ConsumerState<ExerciseSelectionPage> createState() =>
      _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends ConsumerState<ExerciseSelectionPage> {
  final Set<String> _selectedExercises = <String>{};
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  // Valores por defecto para nuevas asignaciones en rutina
  int _defaultSets = 3;
  int _defaultReps = 10;
  double _defaultWeight = 0.0;
  int _defaultRestSeconds = 60;

  final List<String> _categories = [
    'Todos',
    ...ExerciseCategory.values.map((category) => category.displayName),
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
                      itemCount: filteredExercises.length + 1,
                      itemBuilder: (context, index) {
                        // Primer ítem: crear nuevo ejercicio
                        if (index == 0) {
                          return _buildCreateExerciseItem(context, colorScheme);
                        }

                        final exercise = filteredExercises[index - 1];
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
                              exercise.category.displayName,
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
                    exercise.category.displayName.toLowerCase() ==
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

    final bool isSearching = _searchController.text.isNotEmpty;
    final bool isFiltering = _selectedCategory != 'Todos';

    String title;
    String subtitle;
    IconData icon;

    if (isSearching) {
      title = 'No se encontraron ejercicios';
      subtitle = 'Intenta con otros términos de búsqueda';
      icon = Icons.search_off;
    } else if (isFiltering) {
      title = 'No hay ejercicios en esta categoría';
      subtitle = 'No se encontraron ejercicios para $_selectedCategory';
      icon = Icons.category_outlined;
    } else {
      title = 'No tienes ejercicios aún';
      subtitle = 'Comienza agregando tu primer ejercicio';
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
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Acción: Crear nuevo ejercicio
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

                final uri = Uri(
                  path: '/exercise/create',
                  queryParameters: queryParams,
                );
                context.push(uri.toString());
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar ejercicio'),
            ),
            const SizedBox(height: 12),
            // Acciones secundarias según contexto
            if (isSearching)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar búsqueda'),
              ),
            if (isFiltering)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'Todos';
                  });
                },
                child: const Text('Ver todos los ejercicios'),
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

  Widget _buildCreateExerciseItem(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
        ),
        title: const Text('Crear nuevo ejercicio'),
        subtitle: const Text('Añade un ejercicio y vuelve a esta selección'),
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

          final uri = Uri(
            path: '/exercise/create',
            queryParameters: queryParams,
          );
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
    // Prefill con valores previamente usados si hay un único ejercicio seleccionado
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
    final weightController = TextEditingController(
      text: _defaultWeight.toStringAsFixed(1),
    );
    final restController = TextEditingController(
      text: _defaultRestSeconds.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Configurar sets/reps/peso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Repeticiones',
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: restController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Descanso (s)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final parsedSets = int.tryParse(setsController.text.trim()) ?? _defaultSets;
    final parsedReps = int.tryParse(repsController.text.trim()) ?? _defaultReps;
    final parsedWeight =
        double.tryParse(weightController.text.trim()) ?? _defaultWeight;
    final parsedRest =
        int.tryParse(restController.text.trim()) ?? _defaultRestSeconds;

    _defaultSets = parsedSets;
    _defaultReps = parsedReps;
    _defaultWeight = parsedWeight;
    _defaultRestSeconds = parsedRest;

    // Get selected exercises from the exercise notifier
    final exerciseAsync = ref.read(exerciseNotifierProvider);
    exerciseAsync.whenData((exercises) {
      final selectedExercises =
          exercises
              .where((exercise) => _selectedExercises.contains(exercise.id))
              .toList();

      if (selectedExercises.isNotEmpty) {
        // Add exercises to the routine exercise notifier
        final sectionId =
            widget.sectionId ?? 'main_${DateTime.now().millisecondsSinceEpoch}';
        ref
            .read(routineExerciseNotifierProvider.notifier)
            .addExercisesToSection(sectionId, selectedExercises);

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

    // Navegación segura: volver si se puede, si no, ir a Home
    if (Navigator.canPop(context)) {
      if (context.mounted) context.pop();
    } else {
      if (context.mounted) context.go('/');
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
  }) {
    // Get current routine
    final routineAsync = ref.read(routineNotifierProvider);
    routineAsync.whenData((routines) {
      final routine = routines.firstWhere(
        (r) => r.id == routineId,
        orElse: () => throw Exception('Routine not found'),
      );

      // Create RoutineExercise objects
      final routineExercises =
          exercises
              .map(
                (exercise) => RoutineExercise(
                  id: '${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
                  routineSectionId: sectionId,
                  exerciseId: exercise.id,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                  restTimeSeconds: restTime,
                  notes: '',
                  order: 0,
                ),
              )
              .toList();

      // Update the routine with new exercises
      final updatedSections =
          routine.sections.map((section) {
            if (section.id == sectionId) {
              return section.copyWith(
                exercises: [...section.exercises, ...routineExercises],
              );
            }
            return section;
          }).toList();

      final updatedRoutine = routine.copyWith(
        sections: updatedSections,
        updatedAt: DateTime.now(),
      );

      // Save the updated routine
      ref.read(routineNotifierProvider.notifier).updateRoutine(updatedRoutine);
    });
  }

  /// Busca los últimos parámetros usados para un ejercicio en cualquier rutina
  Map<String, Object>? _findLastUsedParamsForExercise(String exerciseId) {
    final routines = ref.read(routineNotifierProvider).valueOrNull;
    if (routines == null) return null;

    for (final routine in routines) {
      for (final section in routine.sections) {
        for (final re in section.exercises) {
          if (re.exerciseId == exerciseId) {
            return <String, Object>{
              'sets': re.sets,
              'reps': re.reps,
              'weight': re.weight,
              'rest': re.restTimeSeconds ?? _defaultRestSeconds,
            };
          }
        }
      }
    }
    return null;
  }
}
