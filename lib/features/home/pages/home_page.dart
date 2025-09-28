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
import '../../../core/database/database_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with RouteAware {
  int _currentIndex = 0;
  String _selectedMenuOption = ''; // Will be set to first active routine

  @override
  void didPopNext() {
    // Se ejecuta cuando se vuelve a esta página desde otra
    super.didPopNext();
    print('HomePage: Volviendo a la página, refrescando estado...');
    // Invalidar el estado para forzar la recarga
    ref.invalidate(routineNotifierProvider);
    ref.invalidate(exerciseNotifierProvider);
  }

  @override
  void initState() {
    super.initState();
    // Refrescar estado al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(routineNotifierProvider);
    });
  }

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
            onPressed: () => context.push('/create-routine'),
            icon: const Icon(Icons.add),
            tooltip: 'Crear nueva rutina',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
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

        print(
          'HomePage: Rebuilding with ${routineAsync.value?.length ?? 0} routines',
        );

        return routineAsync.when(
          data: (routines) {
            // Build menu options from all routines
            final menuOptions = <String>[];

            // Add all routine names to menu
            for (final routine in routines) {
              menuOptions.add(routine.name);
            }

            // Auto-select first routine if none selected or if selected routine no longer exists
            if (_selectedMenuOption.isEmpty ||
                !menuOptions.contains(_selectedMenuOption)) {
              if (menuOptions.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedMenuOption = menuOptions.first;
                  });
                });
              }
            }

            // Always select the first routine (most recent) when routines change
            if (menuOptions.isNotEmpty &&
                _selectedMenuOption != menuOptions.first) {
              print(
                'HomePage: Auto-selecting first routine: ${menuOptions.first} (was: $_selectedMenuOption)',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedMenuOption = menuOptions.first;
                });
              });
            }

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

        print(
          'HomePage MainContent: Rebuilding with ${routineAsync.value?.length ?? 0} routines',
        );

        return routineAsync.when(
          data: (routines) {
            if (routines.isEmpty) {
              return _buildEmptyState();
            }

            // Get selected routine by name
            Routine? selectedRoutine;

            if (_selectedMenuOption.isNotEmpty) {
              try {
                selectedRoutine = routines.firstWhere(
                  (routine) => routine.name == _selectedMenuOption,
                );
              } catch (e) {
                // If selected routine not found, use first routine
                if (routines.isNotEmpty) {
                  selectedRoutine = routines.first;
                }
              }
            } else {
              // No menu option selected, use first routine
              if (routines.isNotEmpty) {
                selectedRoutine = routines.first;
              }
            }

            if (selectedRoutine == null) {
              return _buildEmptyState();
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
    print('HomePage: Building content for routine: ${routine.name}');
    print('HomePage: Total sections: ${routine.sections.length}');

    // Show all sections of the routine
    if (routine.sections.isEmpty) {
      return _buildNoSectionsYet();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routine.sections.length,
      itemBuilder: (context, index) {
        final section = routine.sections[index];
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
          muscleGroup: section.muscleGroup,
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
                return _buildEmptySection(section.name);
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

  Widget _buildNoSectionsYet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay secciones configuradas',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Añade secciones a tu rutina para empezar a entrenar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildEmptySection(String sectionName) {
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
      child: InkWell(
        onTap: () {
          // TODO: Implement add exercise functionality
          print('Add exercise to $sectionName');
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Agregar ejercicios a $sectionName',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(routineNotifierProvider);
                  ref.invalidate(exerciseNotifierProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Resetear base de datos si hay problemas persistentes
                  _showResetDatabaseDialog();
                },
                icon: const Icon(Icons.restore),
                label: const Text('Resetear'),
              ),
            ],
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

  void _showResetDatabaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔄 Resetear Base de Datos'),
        content: const Text(
          'Esto eliminará todos los datos y reiniciará la aplicación.\n\n'
          '¿Estás seguro de que quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _resetDatabase();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDatabase() async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Reseteando base de datos...'),
            ],
          ),
        ),
      );

      final databaseService = ref.read(databaseServiceProvider.notifier);
      await databaseService.forceResetDatabase();
      
      // Invalidar todos los providers
      ref.invalidate(databaseServiceProvider);
      ref.invalidate(routineNotifierProvider);
      ref.invalidate(exerciseNotifierProvider);
      
      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Base de datos reseteada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al resetear: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
