import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/exercise_notifier.dart';
import '../models/exercise.dart';
import '../../../common/enums/muscle_group_enum.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';

class ExerciseListPage extends ConsumerStatefulWidget {
  const ExerciseListPage({super.key});

  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  final TextEditingController _searchController = TextEditingController();
  ExerciseCategory? _selectedCategory;

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
        title: Text(context.tr('exercises.title')),
        backgroundColor: colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'create':
                  context.push('/exercise/create');
                  break;
                case 'quick_add':
                  _showQuickAddDialog(context);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'create',
                    child: Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Nuevo Ejercicio')]),
                  ),
                  PopupMenuItem(
                    value: 'quick_add',
                    child: Row(
                      children: [Icon(Icons.flash_on), SizedBox(width: 8), Text(context.tr('exercises.quickAdd'))],
                    ),
                  ),
                ],
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          _buildSearchAndFilter(),

          // Exercise List
          Expanded(child: _buildExerciseList()),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.tr('exercises.searchExercises'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                      : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('Todos', null),
                const SizedBox(width: 8),
                ...ExerciseCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(_getCategoryName(category), category),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ExerciseCategory? category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildExerciseList() {
    return Consumer(
      builder: (context, ref, child) {
        final exerciseAsync = ref.watch(exerciseNotifierProvider);

        return exerciseAsync.when(
          data: (exercises) {
            final filteredExercises = _filterExercises(exercises);

            if (filteredExercises.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                return _buildExerciseCard(exercise);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: colorScheme.surfaceContainerHighest,
            child: _buildAdaptiveImage(exercise.imageUrl, colorScheme),
          ),
        ),
        title: Text(exercise.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children:
                  exercise.muscleGroups.map((muscle) {
                    return Chip(
                      label: Text(muscle.displayName, style: theme.textTheme.bodySmall),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
        onTap: () => context.push('/exercise/${exercise.id}'),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determinar el contexto del estado vacío
    final bool isSearching = _searchController.text.isNotEmpty;
    final bool isFiltering = _selectedCategory != null;

    String title;
    String subtitle;
    IconData icon;
    List<Widget> actions = [];

    if (isSearching) {
      title = context.tr('exercises.noExercisesFound');
      subtitle = context.tr('exercises.tryOtherSearchTerms');
      icon = Icons.search_off;
    } else if (isFiltering) {
      title = context.tr('exercises.noExercisesInCategory');
      subtitle = 'No se encontraron ejercicios para ${_getCategoryName(_selectedCategory!)}';
      icon = Icons.category_outlined;
      actions = [
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push('/exercise/create'),
          icon: const Icon(Icons.add),
          label: Text(context.tr('exercises.addExercise')),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategory = null;
            });
          },
          child: Text(context.tr('exercises.viewAllExercises')),
        ),
      ];
    } else {
      title = context.tr('exercises.noExercisesYet');
      subtitle = context.tr('exercises.startAddingFirstExercise');
      icon = Icons.fitness_center_outlined;
      actions = [
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push('/exercise/create'),
          icon: const Icon(Icons.add),
          label: const Text('Crear Primer Ejercicio'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showQuickAddDialog(context),
          icon: const Icon(Icons.flash_on),
          label: Text(context.tr('exercises.quickAdd')),
        ),
      ];
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
            ...actions,
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
          Text('Error al cargar los ejercicios', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    var filtered = exercises;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered =
          filtered.where((exercise) {
            return exercise.name.toLowerCase().contains(query) ||
                exercise.description.toLowerCase().contains(query) ||
                exercise.muscleGroups.any((muscle) => muscle.displayName.toLowerCase().contains(query));
          }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered =
          filtered.where((exercise) {
            return exercise.category == _selectedCategory;
          }).toList();
    }

    return filtered;
  }

  String _getCategoryName(ExerciseCategory category) {
    return category.displayName;
  }

  void _showQuickAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    ExerciseCategory selectedCategory = ExerciseCategory.chest;
    ExerciseDifficulty selectedDifficulty = ExerciseDifficulty.beginner;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(context.tr('exercises.quickAddExercise')),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: context.tr('routine.description'),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<ExerciseCategory>(
                                value: selectedCategory,
                                decoration: InputDecoration(
                                  labelText: context.tr('exercises.category'),
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    ExerciseCategory.values.map((category) {
                                      return DropdownMenuItem(value: category, child: Text(category.displayName));
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<ExerciseDifficulty>(
                                value: selectedDifficulty,
                                decoration: const InputDecoration(
                                  labelText: 'Dificultad',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    ExerciseDifficulty.values.map((difficulty) {
                                      return DropdownMenuItem(
                                        value: difficulty,
                                        child: Text(_getDifficultyName(difficulty)),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedDifficulty = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor completa todos los campos'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop();
                        await _createQuickExercise(
                          context,
                          nameController.text.trim(),
                          descriptionController.text.trim(),
                          selectedCategory,
                          selectedDifficulty,
                        );
                      },
                      child: const Text('Crear'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _createQuickExercise(
    BuildContext context,
    String name,
    String description,
    ExerciseCategory category,
    ExerciseDifficulty difficulty,
  ) async {
    try {
      final exercise = Exercise(
        id: '',
        name: name,
        description: description,
        imageUrl: 'assets/images/default_exercise.png',
        videoUrl: null,
        muscleGroups: _getDefaultMuscleGroups(category),
        tips: [context.tr('exercises.maintainFormTip')],
        commonMistakes: ['No mantener la postura adecuada'],
        category: category,
        difficulty: difficulty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(exerciseNotifierProvider.notifier).addExercise(exercise);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$name creado correctamente'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear ejercicio: $e'), backgroundColor: Colors.red));
      }
    }
  }

  List<MuscleGroup> _getDefaultMuscleGroups(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return [MuscleGroup.pectoralMajor, MuscleGroup.anteriorDeltoid];
      case ExerciseCategory.back:
        return [MuscleGroup.latissimusDorsi, MuscleGroup.rhomboids];
      case ExerciseCategory.shoulders:
        return [MuscleGroup.medialDeltoid, MuscleGroup.anteriorDeltoid];
      case ExerciseCategory.biceps:
        return [MuscleGroup.bicepsLongHead, MuscleGroup.bicepsShortHead];
      case ExerciseCategory.triceps:
        return [MuscleGroup.tricepsLateralHead, MuscleGroup.tricepsLongHead];
      case ExerciseCategory.quadriceps:
        return [MuscleGroup.rectusFemoris, MuscleGroup.vastusLateralis];
      case ExerciseCategory.hamstrings:
        return [MuscleGroup.bicepsFemoris, MuscleGroup.semitendinosus];
      case ExerciseCategory.glutes:
        return [MuscleGroup.gluteusMaximus, MuscleGroup.gluteusMedius];
      case ExerciseCategory.calves:
        return [MuscleGroup.gastrocnemius, MuscleGroup.soleus];
      case ExerciseCategory.core:
        return [MuscleGroup.rectusAbdominis, MuscleGroup.externalObliques];
      case ExerciseCategory.forearms:
        return [MuscleGroup.forearmFlexors, MuscleGroup.forearmExtensors];
      case ExerciseCategory.cardio:
        return [MuscleGroup.rectusFemoris, MuscleGroup.gluteusMaximus];
      case ExerciseCategory.fullBody:
        return [
          MuscleGroup.pectoralMajor,
          MuscleGroup.latissimusDorsi,
          MuscleGroup.rectusFemoris,
          MuscleGroup.gluteusMaximus,
        ];
    }
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

  Widget _buildAdaptiveImage(String path, ColorScheme colorScheme) {
    if (path.isEmpty) {
      return Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant);
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
      );
    }

    final String filePath = path.startsWith('file:') ? path.replaceFirst('file://', '') : path;
    return Image.file(
      File(filePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: colorScheme.onSurfaceVariant),
    );
  }
}
