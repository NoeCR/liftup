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

    final menuOptions = [
      'Hoy',
      'Pecho',
      'Pierna',
      'Cardio',
      'Lunes',
      'Martes',
      'Miércoles',
    ];

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

            // Get today's routine
            final todayRoutine = _getTodayRoutine(routines);
            if (todayRoutine == null) {
              return _buildNoRoutineForToday();
            }

            return _buildRoutineContent(todayRoutine, exerciseAsync);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildRoutineContent(
    RoutineDay routineDay,
    AsyncValue<List<Exercise>> exerciseAsync,
  ) {
    return ListView.builder(
      itemCount: routineDay.sections.length,
      itemBuilder: (context, index) {
        final section = routineDay.sections[index];
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
              print('DEBUG: Navegando a crear rutina...');
              try {
                context.push('/create-routine');
                print('DEBUG: Navegación exitosa');
              } catch (e) {
                print('DEBUG: Error en navegación: $e');
              }
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
              print('DEBUG: Navegando a crear rutina...');
              try {
                context.push('/create-routine');
                print('DEBUG: Navegación exitosa');
              } catch (e) {
                print('DEBUG: Error en navegación: $e');
              }
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

  RoutineDay? _getTodayRoutine(List<Routine> routines) {
    final today = DateTime.now().weekday;
    final weekDay = _getWeekDayFromInt(today);

    for (final routine in routines) {
      if (!routine.isActive) continue;

      for (final day in routine.days) {
        if (day.dayOfWeek == weekDay && day.isActive) {
          return day;
        }
      }
    }

    return null;
  }

  WeekDay _getWeekDayFromInt(int weekday) {
    switch (weekday) {
      case 1:
        return WeekDay.monday;
      case 2:
        return WeekDay.tuesday;
      case 3:
        return WeekDay.wednesday;
      case 4:
        return WeekDay.thursday;
      case 5:
        return WeekDay.friday;
      case 6:
        return WeekDay.saturday;
      case 7:
        return WeekDay.sunday;
      default:
        return WeekDay.monday;
    }
  }
}
