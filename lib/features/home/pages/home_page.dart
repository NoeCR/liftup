import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/routine_notifier.dart';
import '../../exercise/notifiers/exercise_notifier.dart';
import '../notifiers/selected_routine_provider.dart';
import '../notifiers/auto_routine_selection_notifier.dart';
import '../../sessions/notifiers/session_notifier.dart';
import '../../../common/widgets/section_header.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../widgets/exercise_card_wrapper.dart';
import '../widgets/auto_selection_info_card.dart';
import '../models/routine.dart';
import '../../exercise/models/exercise.dart';
import '../../../core/database/database_service.dart';
import '../../sessions/models/workout_session.dart';
import '../../../common/themes/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with RouteAware {
  final int _currentIndex = 0;
  String _selectedMenuOption = ''; // Will be set to first active routine

  @override
  void didPopNext() {
    // Runs when returning to this page from another
    super.didPopNext();
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
        title: Text(context.tr('app.title')),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: context.tr('home.manageRoutines'),
            onPressed: () => _showRoutineManagement(context, ref),
            icon: const Icon(Icons.reorder),
          ),
        ],
      ),
      body: Column(
        children: [
          // Configurable Menu
          _buildConfigurableMenu(),

          // Auto Selection Info
          const AutoSelectionInfoCard(),

          // Main Content
          Expanded(child: _buildMainContent()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: _currentIndex),
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
            // Build menu options from all routines
            final menuOptions = <String>[];

            // Add all routine names to menu
            for (final routine in routines) {
              menuOptions.add(routine.name);
            }

            // Auto-select routine based on day of week or first routine if none selected
            if (_selectedMenuOption.isEmpty || !menuOptions.contains(_selectedMenuOption)) {
              if (menuOptions.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Get auto-selected routine or fallback to first
                  final autoSelectionInfo = ref.read(autoRoutineSelectionNotifierProvider);
                  final routines = ref.read(routineNotifierProvider).value ?? [];

                  Routine? routineToSelect;
                  if (autoSelectionInfo.hasSelection) {
                    // Use auto-selected routine for today
                    routineToSelect = autoSelectionInfo.selectedRoutine;
                  } else if (routines.isNotEmpty) {
                    // Fallback to first routine
                    routineToSelect = routines.first;
                  }

                  if (routineToSelect != null) {
                    setState(() {
                      _selectedMenuOption = routineToSelect!.name;
                    });
                    ref.read(selectedRoutineIdProvider.notifier).state = routineToSelect.id;
                  }
                });
              }
            }

            return _buildMenuOptions(menuOptions, theme, colorScheme);
          },
          loading: () => _buildMenuOptions([context.tr('home.today')], theme, colorScheme),
          error: (error, stack) => _buildMenuOptions([context.tr('home.today')], theme, colorScheme),
        );
      },
    );
  }

  Widget _buildMenuOptions(List<String> menuOptions, ThemeData theme, ColorScheme colorScheme) {
    final hasActiveSession =
        ref
            .watch(sessionNotifierProvider)
            .maybeWhen(
              data:
                  (sessions) => sessions.any(
                    (s) => (s.status == SessionStatus.active || s.status == SessionStatus.paused) && s.endTime == null,
                  ),
              orElse: () => false,
            ) ==
        true;
    return Container(
      height: 76,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: menuOptions.length,
        itemBuilder: (context, index) {
          final option = menuOptions[index];
          final isSelected = _selectedMenuOption == option;
          final routinesList = ref.read(routineNotifierProvider).value;
          final Routine? routineForCard =
              routinesList == null || routinesList.isEmpty
                  ? null
                  : routinesList.firstWhere((r) => r.name == option, orElse: () => routinesList.first);
          final int sectionsCount = routineForCard?.sections.length ?? 0;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingM),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              onTap:
                  hasActiveSession
                      ? null
                      : () {
                        setState(() {
                          _selectedMenuOption = option;
                        });
                        final routines = ref.read(routineNotifierProvider).value;
                        final routine = routines?.firstWhere((r) => r.name == option, orElse: () => routines.first);
                        ref.read(selectedRoutineIdProvider.notifier).state = routine?.id;
                      },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 180,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: AppTheme.elevationXL,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary.withValues(alpha: 0.35)
                            : colorScheme.outline.withValues(alpha: 0.20),
                  ),
                ),
                padding: const EdgeInsets.all(AppTheme.spacingS),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_rounded : Icons.fitness_center_rounded,
                        color: isSelected ? colorScheme.onPrimary : colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingS,
                                  vertical: AppTheme.spacingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                ),
                                child: Text(
                                  '$sectionsCount ${context.tr('settings.routines').toLowerCase() == 'rutinas' ? 'secciones' : 'sections'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

            // Get selected routine by name
            Routine? selectedRoutine;

            if (_selectedMenuOption.isNotEmpty) {
              try {
                selectedRoutine = routines.firstWhere((routine) => routine.name == _selectedMenuOption);
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

  Widget _buildRoutineContent(Routine routine, AsyncValue<List<Exercise>> exerciseAsync) {
    // Show all sections of the routine
    if (routine.sections.isEmpty) {
      return _buildNoSectionsYet();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavigationBarHeight + AppTheme.spacingL),
      itemCount: routine.sections.length,
      itemBuilder: (context, index) {
        final section = routine.sections[index];
        return _buildRoutineSection(section, exerciseAsync, routine);
      },
    );
  }

  Widget _buildRoutineSection(RoutineSection section, AsyncValue<List<Exercise>> exerciseAsync, Routine routine) {
    return Column(
      children: [
        SectionHeader(
          title: section.name,
          isCollapsed: section.isCollapsed,
          iconName: section.iconName,
          muscleGroup: section.muscleGroup,
          onToggleCollapsed: () {
            ref.read(routineNotifierProvider.notifier).toggleSectionCollapsed(section.id);
          },
        ),
        if (!section.isCollapsed) ...[
          exerciseAsync.when(
            data: (exercises) {
              if (section.exercises.isEmpty) {
                return _buildEmptySection(section.name, routine, section);
              }

              final exerciseCards =
                  section.exercises.map((routineExercise) {
                    final exercise = exercises.firstWhere(
                      (e) => e.id == routineExercise.exerciseId,
                      orElse:
                          () => Exercise(
                            id: '',
                            name: context.tr('errors.exerciseNotFound'),
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
                  }).toList();

              // Carrusel horizontal de ejercicios
              return SizedBox(
                height: 308,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
                  itemCount: exerciseCards.length + 1,
                  itemBuilder: (context, index) {
                    if (index == exerciseCards.length) {
                      // Last item: card to add exercises
                      return SizedBox(width: 320, child: _buildEmptySection(section.name, routine, section));
                    }
                    return SizedBox(width: 320, child: exerciseCards[index]);
                  },
                ),
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
          Icon(Icons.fitness_center_outlined, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(context.tr('app.welcome'), style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.tr('app.createFirstRoutine'),
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.push('/create-routine');
            },
            icon: const Icon(Icons.add),
            label: Text(context.tr('app.createRoutine')),
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
          Icon(Icons.category_outlined, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(context.tr('home.noSectionsConfigured'), style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            context.tr('home.addSectionsToStart'),
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String sectionName, Routine routine, RoutineSection section) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), style: BorderStyle.solid),
      ),
      child: Consumer(
        builder: (context, ref, _) {
          final hasActiveSession =
              ref
                  .watch(sessionNotifierProvider)
                  .maybeWhen(
                    data:
                        (sessions) => sessions.any(
                          (s) =>
                              (s.status == SessionStatus.active || s.status == SessionStatus.paused) &&
                              s.endTime == null,
                        ),
                    orElse: () => false,
                  ) ==
              true;
          return InkWell(
            onTap:
                hasActiveSession
                    ? null
                    : () {
                      context.push(
                        '/exercise-selection?routineId=${routine.id}&sectionId=${section.id}&title=Agregar Ejercicios&subtitle=$sectionName',
                      );
                    },
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: hasActiveSession ? 0.4 : 1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasActiveSession
                          ? context.tr('home.editingBlockedDuringSession')
                          : context.tr('home.addExercisesToSection', namedArgs: {'sectionName': sectionName}),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (!hasActiveSession)
                      Text(
                        context.tr('home.tapToAddExercises'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Persistent tile removed per new carousel + empty card UX

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(context.tr('errors.errorLoadingData'), style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
                label: Text(context.tr('home.retry')),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Resetear base de datos si hay problemas persistentes
                  _showResetDatabaseDialog();
                },
                icon: const Icon(Icons.restore),
                label: Text(context.tr('home.reset')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetDatabaseDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('home.resetDatabase')),
            content: Text(context.tr('home.resetDatabaseDescription')),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('common.cancel'))),
              FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _resetDatabase();
                },
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: Text(context.tr('home.reset')),
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
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(context.tr('home.resettingDatabase')),
                ],
              ),
            ),
      );

      final databaseService = DatabaseService.getInstance();
      await databaseService.forceResetDatabase();

      // Invalidar todos los providers
      ref.invalidate(routineNotifierProvider);
      ref.invalidate(exerciseNotifierProvider);

      // Cerrar indicador de progreso
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('home.databaseResetSuccess')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('home.databaseResetError', namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRoutineManagement(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(context.tr('home.manageRoutinesTitle')),
            content: Text(context.tr('home.manageRoutinesDescription')),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.tr('home.understood'))),
            ],
          ),
    );
  }
}
