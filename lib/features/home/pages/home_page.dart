import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../../../common/widgets/section_header.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../widgets/exercise_card_wrapper.dart';
import '../models/routine.dart';
import '../../exercise/models/exercise.dart';
import '../../../common/enums/week_day_enum.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  String _selectedMenuOption = 'Hoy';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LiftUp'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Configurable Menu
          _buildConfigurableMenu(),

          // Main Content
          Expanded(child: _buildMainContent()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: _currentIndex),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildConfigurableMenu() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final routineAsync = ref.watch(routineNotifierProvider);

        return routineAsync.when(
          data: (routines) {
            // Build menu options from routines
            final menuOptions = <String>['Hoy'];

            // Add routine names to menu
            for (final routine in routines) {
              if (routine.isActive) {
                menuOptions.add(routine.name);
              }
            }

            // Add day options
            menuOptions.addAll(WeekDayExtension.allDisplayNames);

            return _buildMenuOptions(menuOptions, theme, colorScheme);
          },
          loading: () => _buildMenuOptions(['Hoy'], theme, colorScheme),
          error:
              (error, stack) => _buildMenuOptions(['Hoy'], theme, colorScheme),
        );
      },
    );
  }

  Widget _buildMenuOptions(
    List<String> menuOptions,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: menuOptions.length,
        itemBuilder: (context, index) {
          final option = menuOptions[index];
          final isSelected = _selectedMenuOption == option;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMenuOption = option;
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer(
      builder: (context, ref, child) {
        final routineAsync = ref.watch(routineNotifierProvider);
        final exerciseAsync = ref.watch(exerciseNotifierProvider);

        return routineAsync.when(
          data: (routines) {
            if (routines.isEmpty) {
              return _buildEmptyState();
            }

            // Get selected routine or today's routine
            Routine? selectedRoutine;

            if (_selectedMenuOption == 'Hoy') {
              selectedRoutine = _getTodayRoutine(routines);
              if (selectedRoutine == null) {
                return _buildNoRoutineForToday();
              }
            } else if (_isDayOfWeek(_selectedMenuOption)) {
              // Get routine for selected day
              final selectedDay = WeekDayExtension.fromString(_selectedMenuOption);
              selectedRoutine = routines.firstWhere(
                (routine) =>
                    routine.days.any((day) => day.dayOfWeek == selectedDay),
                orElse: () => routines.first,
              );
            } else {
              // Get routine by name
              selectedRoutine = routines.firstWhere(
                (routine) => routine.name == _selectedMenuOption,
                orElse: () => routines.first,
              );
            }

            return _buildRoutineContent(selectedRoutine, exerciseAsync);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildRoutineContent(
    Routine routine,
    AsyncValue<List<Exercise>> exerciseAsync,
  ) {
    // Get the appropriate day from the routine
    RoutineDay? routineDay;

    if (_selectedMenuOption == 'Hoy') {
      final today = DateTime.now().weekday;
      final weekDay = WeekDayExtension.fromInt(today);
      routineDay = routine.days.firstWhere(
        (day) => day.dayOfWeek == weekDay && day.isActive,
        orElse: () => routine.days.first,
      );
    } else if (_isDayOfWeek(_selectedMenuOption)) {
      final selectedDay = WeekDayExtension.fromString(_selectedMenuOption);
      routineDay = routine.days.firstWhere(
        (day) => day.dayOfWeek == selectedDay && day.isActive,
        orElse: () => routine.days.first,
      );
    } else {
      // For routine name selection, show the first day
      if (routine.days.isEmpty) {
        return _buildNoRoutineForToday();
      }
      routineDay = routine.days.first;
    }

    final selectedDay = routineDay;
    return ListView.builder(
      itemCount: selectedDay.sections.length,
      itemBuilder: (context, index) {
        final section = selectedDay.sections[index];
        return _buildRoutineSection(section, exerciseAsync);
      },
    );
  }

  Widget _buildRoutineSection(
    RoutineSection section,
    AsyncValue<List<Exercise>> exerciseAsync,
  ) {
    return Column(
      children: [
        SectionHeader(
          title: section.name,
          isCollapsed: section.isCollapsed,
          iconName: section.iconName,
          onToggleCollapsed: () {
            ref
                .read(routineNotifierProvider.notifier)
                .toggleSectionCollapsed(section.id);
          },
        ),
        if (!section.isCollapsed) ...[
          exerciseAsync.when(
            data: (exercises) {
              if (section.exercises.isEmpty) {
                return _buildEmptySection();
              }

              return Column(
                children:
                    section.exercises.map((routineExercise) {
                      final exercise = exercises.firstWhere(
                        (e) => e.id == routineExercise.exerciseId,
                        orElse:
                            () => Exercise(
                              id: '',
                              name: 'Ejercicio no encontrado',
                              description: '',
                              imageUrl: '',
                              muscleGroups: [],
                              tips: [],
                              commonMistakes: [],
                              category: ExerciseCategory.fullBody,
                              difficulty: ExerciseDifficulty.beginner,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                      );

                      return ExerciseCardWrapper(
                        routineExercise: routineExercise,
                        exercise: exercise,
                        onTap: () => context.push('/exercise/${exercise.id}'),
                      );
                    }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('¡Bienvenido a LiftUp!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera rutina para comenzar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.push('/create-routine');
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Rutina'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRoutineForToday() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No hay rutina para hoy', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Disfruta de un día de descanso o crea una rutina',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.push('/create-routine');
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Rutina'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Agregar ejercicios',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca para agregar ejercicios a esta sección',
            style: theme.textTheme.bodySmall?.copyWith(
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
            'Error al cargar los datos',
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
              ref.invalidate(routineNotifierProvider);
              ref.invalidate(exerciseNotifierProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () => context.push('/session'),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Entrenar'),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    );
  }

  Routine? _getTodayRoutine(List<Routine> routines) {
    final today = DateTime.now().weekday;
    final weekDay = WeekDayExtension.fromInt(today);

    for (final routine in routines) {
      if (!routine.isActive) continue;

      for (final day in routine.days) {
        if (day.dayOfWeek == weekDay && day.isActive) {
          return routine;
        }
      }
    }

    return null;
  }

  bool _isDayOfWeek(String option) {
    return WeekDayExtension.allDisplayNames.contains(option);
  }
}
